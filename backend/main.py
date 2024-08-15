from fastapi import FastAPI, Depends, HTTPException, Response, Body
from fastapi.responses import RedirectResponse
from sqlalchemy.orm import Session
import models, database
import string
import random
from fastapi.middleware.cors import CORSMiddleware


app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

models.Base.metadata.create_all(bind=database.engine)

def generate_short_code(alias: str, length=6):
    if alias:  # If alias is provided, use it
        return alias
    else:  # Generate a random short code if no alias is provided
        return ''.join(random.choices(string.ascii_letters + string.digits, k=length))

def make_unique_alias(alias: str, db: Session):
    original_alias = alias
    while db.query(models.URL).filter(models.URL.short_code == alias).first():
        alias = original_alias + ''.join(random.choices(string.ascii_letters + string.digits, k=4))
    return alias

@app.get("/")
def hello():
    return Response("<h1>Welcome</h1>", media_type="text/html")

@app.post("/shorten")
def shorten_url(original_url: str = Body(..., embed=True), alias: str = Body("", embed=True), db: Session = Depends(database.get_db)):
    if alias:
        alias = make_unique_alias(alias, db)
    else:
        alias = generate_short_code(alias)

    url = models.URL(original_url=original_url, short_code=alias)
    db.add(url)
    db.commit()
    db.refresh(url)
    return {"shortened_url": f"http://localhost:8000/{alias}"}

@app.get("/{short_code}")
def redirect_url(short_code: str, db: Session = Depends(database.get_db)):
    url = db.query(models.URL).filter(models.URL.short_code == short_code).first()
    if not url:
        raise HTTPException(status_code=404, detail="URL not found")
    
    # Perform the actual redirect
    return RedirectResponse(url.original_url)
