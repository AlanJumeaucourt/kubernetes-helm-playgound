FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

LABEL version="1.0.8" \
      description="Todo App Backend API - Using Plain SQL and Marshmallow" \
      maintainer="Alan Jumeaucourt <git@mail.jumeaucourt.com>"

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]
