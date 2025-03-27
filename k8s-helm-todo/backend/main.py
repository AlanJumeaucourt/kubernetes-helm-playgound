import os
from typing import Any, Dict, Generator, List
from datetime import datetime

import psycopg2
import psycopg2.extras
from fastapi import Depends, FastAPI, HTTPException
from marshmallow import Schema, ValidationError, fields
from psycopg2.extensions import connection
from psycopg2.extras import RealDictCursor

# Database configuration
DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://postgres:postgres@db:5432/todos")

app = FastAPI(title="Todo API", version="1.0.7")


# Helper function to get database connection
def get_db() -> Generator[connection, None, None]:
    conn = psycopg2.connect(DATABASE_URL)
    try:
        yield conn
    finally:
        conn.close()


# Create tables if they don't exist
def init_db() -> None:
    conn = psycopg2.connect(DATABASE_URL)
    cur = conn.cursor()
    try:
        cur.execute("""
            CREATE TABLE IF NOT EXISTS todos (
                id SERIAL PRIMARY KEY,
                title VARCHAR(255) NOT NULL,
                description TEXT,
                completed BOOLEAN DEFAULT FALSE
            )
        """)
        
        # Check if completion_date column exists, if not add it
        cur.execute("""
            SELECT column_name FROM information_schema.columns 
            WHERE table_name='todos' AND column_name='completion_date'
        """)
        if not cur.fetchone():
            cur.execute("ALTER TABLE todos ADD COLUMN completion_date TIMESTAMP")
        
        conn.commit()
    finally:
        cur.close()
        conn.close()


# Initialize database
init_db()


# Type definitions for validated data
TodoData = Dict[str, Any]


# Marshmallow schemas for validation
class TodoBaseSchema(Schema):
    title = fields.String(required=True)
    description = fields.String(allow_none=True)


class TodoCreateSchema(TodoBaseSchema):
    pass


class TodoUpdateSchema(Schema):
    title = fields.String(required=False, allow_none=True)
    description = fields.String(required=False, allow_none=True)
    completed = fields.Boolean(required=False, allow_none=True)
    completion_date = fields.DateTime(required=False, allow_none=True)


class TodoSchema(TodoBaseSchema):
    id = fields.Integer()
    completed = fields.Boolean()
    completion_date = fields.DateTime(allow_none=True)


todo_schema = TodoSchema()
todos_schema = TodoSchema(many=True)
todo_create_schema = TodoCreateSchema()
todo_update_schema = TodoUpdateSchema()


@app.get("/todos")
def read_todos(conn: connection = Depends(get_db)) -> List[Dict[str, Any]]:
    try:
        cur = conn.cursor(cursor_factory=RealDictCursor)
        cur.execute("SELECT * FROM todos")
        # Need to convert RealDictRow to Dict to satisfy the type checker
        todos = [dict(todo) for todo in cur.fetchall()]
        cur.close()
        return todos
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/todos")
def create_todo(
    todo_data: Dict[str, Any], conn: connection = Depends(get_db)
) -> Dict[str, Any]:
    try:
        # Validate input
        validated_data: TodoData = todo_create_schema.load(todo_data)

        cur = conn.cursor(cursor_factory=RealDictCursor)
        cur.execute(
            "INSERT INTO todos (title, description) VALUES (%s, %s) RETURNING *",
            (validated_data.get("title"), validated_data.get("description")),
        )
        new_todo = dict(cur.fetchone())
        conn.commit()
        cur.close()
        return new_todo
    except ValidationError as err:
        raise HTTPException(status_code=422, detail=str(err.messages))
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.put("/todos/{todo_id}")
def update_todo(
    todo_id: int, todo_data: Dict[str, Any], conn: connection = Depends(get_db)
) -> Dict[str, Any]:
    try:
        # Validate input
        validated_data: TodoData = todo_update_schema.load(todo_data)

        # Check if the todo exists
        cur = conn.cursor(cursor_factory=RealDictCursor)
        cur.execute("SELECT * FROM todos WHERE id = %s", (todo_id,))
        existing_todo = cur.fetchone()

        if not existing_todo:
            raise HTTPException(status_code=404, detail="Todo not found")

        # Build the update query dynamically based on provided fields
        update_fields: List[str] = []
        params: List[Any] = []

        if "title" in validated_data:
            update_fields.append("title = %s")
            params.append(validated_data.get("title"))

        if "description" in validated_data:
            update_fields.append("description = %s")
            params.append(validated_data.get("description"))

        if "completed" in validated_data:
            update_fields.append("completed = %s")
            params.append(validated_data.get("completed"))
            
            # Update completion_date automatically when completed status changes
            if validated_data.get("completed"):
                update_fields.append("completion_date = %s")
                params.append(datetime.now())
            else:
                update_fields.append("completion_date = %s")
                params.append(None)
        
        # Allow explicit setting of completion_date
        if "completion_date" in validated_data and "completed" not in validated_data:
            update_fields.append("completion_date = %s")
            params.append(validated_data.get("completion_date"))

        if not update_fields:
            return dict(existing_todo)

        # Add the todo_id to the params
        params.append(todo_id)

        # Execute the update
        query = f"UPDATE todos SET {', '.join(update_fields)} WHERE id = %s RETURNING *"
        cur.execute(query, params)
        updated_todo = dict(cur.fetchone())
        conn.commit()
        cur.close()

        return updated_todo
    except ValidationError as err:
        raise HTTPException(status_code=422, detail=str(err.messages))
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.delete("/todos/{todo_id}")
def delete_todo(todo_id: int, conn: connection = Depends(get_db)) -> Dict[str, str]:
    try:
        cur = conn.cursor()

        # Check if the todo exists
        cur.execute("SELECT id FROM todos WHERE id = %s", (todo_id,))
        if not cur.fetchone():
            raise HTTPException(status_code=404, detail="Todo not found")

        # Delete the todo
        cur.execute("DELETE FROM todos WHERE id = %s", (todo_id,))
        conn.commit()
        cur.close()

        return {"message": f"Todo {todo_id} deleted successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/health")
def health_check() -> Dict[str, str]:
    try:
        # Test database connection
        conn = psycopg2.connect(DATABASE_URL)
        conn.close()
        return {"status": "healthy"}
    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Database connection failed: {str(e)}"
        )
