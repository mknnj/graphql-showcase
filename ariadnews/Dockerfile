FROM python:3

EXPOSE 8000

RUN mkdir /app

COPY ./requirements.txt /app/requirements.txt
WORKDIR /app

RUN pip install -r requirements.txt
COPY . /app

CMD uvicorn main:graphql_app --host 0.0.0.0