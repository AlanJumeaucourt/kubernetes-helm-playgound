import os

from fastapi import FastAPI
from pydantic import BaseModel
from sqlalchemy import Boolean, Column, Integer, String, create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

# Database configuration
DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://postgres:postgres@db:5432/todos")

# SQLAlchemy setup
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()


# Database model
class TodoModel(Base):
    __tablename__ = "todos"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, index=True)
    description = Column(String)
    completed = Column(Boolean, default=False)


# Create tables
Base.metadata.create_all(bind=engine)


# Pydantic models
class TodoBase(BaseModel):
    title: str
    description: str | None = None


class TodoCreate(TodoBase):
    pass


class Todo(TodoBase):
    id: int
    completed: bool

    class Config:
        from_attributes = True


app = FastAPI(title="Todo API", version="1.0.0")


# Dependency
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


@app.get("/todos", response_model=list[Todo])
def read_todos():
    db = SessionLocal()
    try:
        todos = db.query(TodoModel).all()
        return todos
    finally:
        db.close()


@app.post("/todos", response_model=Todo)
def create_todo(todo: TodoCreate):
    db = SessionLocal()
    try:
        db_todo = TodoModel(**todo.model_dump())
        db.add(db_todo)
        db.commit()
        db.refresh(db_todo)
        return db_todo
    finally:
        db.close()


@app.get("/health")
def health_check():
    return {"status": "healthy"}
