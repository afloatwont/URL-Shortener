from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

# DATABASE_URL = "postgresql://postgres:root@localhost/url_shortener"
DATABASE_URL = "postgresql://url_shortener_25ps_user:InjfclxQNp3snhATCjEFICSruJN9qHrr@dpg-cqv3l5rtq21c73a1jbk0-a.singapore-postgres.render.com/url_shortener_25ps"

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
