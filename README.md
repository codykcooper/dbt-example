# This repo is still a work in progress. Sorry for typos and unorganized writing. 

The goal of this project is simply to demonstrate some fundamental [dbt](https://www.getdbt.com/) concepts. 

#### Quick Note; Reliance on docker
This project relies on docker to get around the worry of having to ensure a systems is configured properly or going through the steps of setting up a virtual environment within a given OS.  
Docker is used to dev / serve the dbt workflow and is used to set up the database (PostgresSQL) the project connects to. 

### Goals of the project
- Demonstrate basic setup and configuration
- Show the workflow for developing simple data models
- Demonstrate dbt built-in documentation features

## Step 1: Set up a database
First step of the project is to set up a database in order to store and access data. DBT is not universally compatible with all databses, but is compatible with popular choices. For this project I went with a Postgres db. In order to launch the db, you can run the following docker code in terminal to get it launched and running locally. 

```docker
#set up postgres docker image
docker run --name pg_local -p 5432:5432 \
-e POSTGRES_USER=tbd_insur -e POSTGRES_PASSWORD=insur_pw \
-e POSTGRES_DB=tutorial -d postgres:12.2
```

Take note of the username and password above, as this is needed when configuring DBT.  

## Step 2: Configure DBT to access postgres database

### Configure connection to databse
To set up access to databses, dbt requires a profiles.yml file typically stored in ~/.dbt . Since this projct will be ran in docker, you can place the profiles.yml file anywhere, as it will be mounted into the docker iamge. the basic set up for the file is as follows. 

```yml
tbd_insur:
  outputs:
    dev:
      type: postgres
      threads: 1
      host: 172.17.0.1
      port: 5432
      user: tbd_insur
      pass: insur_pw
      dbname: tutorial
      schema: insur_data
  target: dev
```

A few things to note from above:

- The user name and password match what was passed when creating the postgres docker image. 
- tbd_insur is a profile name that needs to match the profile name set up in dbt_projects.yml (more below).
- For me, host needs to be set to 172.17.0.1 in order to access the database from within the docker image.
- `dbname` and `schema` do not need to be pre-specified in the the postgres databse. DBT will handle creating them if they do not exist. 

After creating the profile.yml file the rest of the project can be created from the files in this repo. 


## Step 3: Create DBT docker image

Once this repo has been pulled navigate a terminal into the repo directory where there dockerfile is present. Once in the docker image run the following docker command:

```docker
docker build . -t dbt_example
```

The above code builds a docker image based on the code present in `dockerfile`:

```docker
FROM python:3.8.5

# Update and install system packages
RUN apt-get update -y && \
  apt-get install --no-install-recommends -y -q \
  git libpq-dev python-dev && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install DBT
RUN pip install -U pip
RUN pip install dbt==0.19.0

# Set environment variables
ENV DBT_DIR /dbt

# Set working directory
WORKDIR $DBT_DIR

#Expose port 8080 for dbt documentation
EXPOSE 8080
```

The above code creates a docker image called `dbt_example` that we can use to launch the dbt projcts. Before launching you will need to identify the location of your profiles.yml file and the repo location. 

To launch the docker image run docker command:

``` docker
docker run -p 8080:8080 --name dbt -it -d \
-v /Users/codycooper/.dbt/profiles.yml:/root/.dbt/profiles.yml \
-v /Users/codycooper/Documents/GitHub/dbt-example:/dbt \
-d dbt_example:latest
```

Note you'll need to adjust each path after `-v` to wherever you have the two files saved, so that they are appropriately mounted into the docker image. 

Afer running the above you should have a functioning docker image that can be used to explore the dbt project / environment. 

Generally, the dockerfile or image would be configured to execute commands on launch. For the purpose of this tutorial, I am simply going enter the docker image an manually show how to run some standard dbt commands. 

To test if the project code has been set up correctly run:

```dbt
dbt compile
```

To run all of the models and see them in the postgres databse run:

```
dbt run
```

dbt comes packeged with the ability to manage and serve documentation to users. This documentation can occur in multiple places, with the main source of documentation stored in src_insur_data.yml for this project. In order to generate and serve dbt documentation run:

```
dbt docs generate

dbt docs serve
```

After running the serve command, you can view documentation by navigating to http://localhost:8080/

### Resources highlighted by DBT:
- Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [chat](http://slack.getdbt.com/) on Slack for live discussions and support
- Find [dbt events](https://events.getdbt.com) near you
- Check out [the blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices
