# Prompts used

## Convert to nx add java backend service

prompt got lost, duh! This is the summary Copilot made about the change:

```
This PR transforms the standalone React barcode wallet application into a comprehensive Nx monorepo
with integrated frontend and backend services. The project now includes a Java Spring Boot REST API
backend alongside the existing React PWA frontend.
```

## Connect frontend to Java backend

```
the front end currently doesn't store data in the backend services. change the front end so that it
connects to the backend and stores data using the services defined in barcodecontroller.java. test
if the data is stored correctly and make sure to save the logs of this test in the docs folder
```

## Store data in a Postgres database

```
act like a software architect. now i want to store data in a Postgres database, so it doesn't get
lost when the backend is restarted. consider using industry standard patterns to solve this problem.
how would you store credentials for the connection to the database?
```

This prompt was a bit too focussed, it returned an answer to the question of how to store credentials. 
that would only solve part of the problem, the code still needs to be updated to use the database.

Then I asked

```
how would you change the code to access the database?
```

and got a list of all changes to be made. i wanted to delegate the work to an agent, so i need a plan. 

I guess I should be more specific:

```
make a plan to change the code so it uses postgres to store data
```

Now I got this:

```
Use Postgres for data storage in your Spring Boot backend:
- Add Postgres JDBC Driver Dependency: Add the Postgres driver to your backend/pom.xml.
- Configure Database Connection: Set up connection properties in backend/src/main/resources/application.properties using environment variables for credentials.
- Create a JPA Entity: Refactor your model (e.g., BarcodeItem) to be a JPA entity with appropriate annotations.
- Create a Spring Data JPA Repository: Add a repository interface for your entity.
- Update Controller/Service: Refactor BarcodeController to use the repository for CRUD operations.
- Database Initialization: Set spring.jpa.hibernate.ddl-auto=update for automatic schema updates during development.
- Test the Integration: Run the backend, verify data is persisted in Postgres, and update tests if needed.
- Secure Credentials: Ensure credentials are not hardcoded or committed; use environment variables or a secrets manager.
- Document the Setup: Add setup instructions for local development and production environments.
- test if the data is stored correctly and make sure to save the logs of this test in the docs/addPostgres folder
```

That looks good. I added 

```
test if the data is stored correctly and make sure to save the logs of this test in the docs/addPostgres folder
```

I'm hoping I'll get a new folder in docs named `docs/addPostgres`, because in the previous change 
all the logs for my second task got dumped in docs. I wanted a log per task, so I need a folder. 
Hope this does the trick...

This sort of worked, but the database setup is hard to follow. So i added a docker-compose file to `apps/backend` and 
set the database connection properties accordingly in the .env file. The file should look like this

```
REACT_APP_VERSION=16
DATABASE_URL=jdbc:postgresql://localhost:5432/barcodes
DATABASE_USERNAME=postgres
DATABASE_PASSWORD=<set your password here>
```

Starting the backend from the root of this project works like this:

```bash
# start the database
(cd apps/backend/ && docker-compose up -d)
# start the backend
npx nx serve backend
```

