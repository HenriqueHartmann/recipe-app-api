# IMAGE TAG
# Alpine is a light version of Linux and is ideal to running docker containers.
# It's very stripped back. It doesn't have any unnecessary dependencies that you would need.
# Everything that it comes with is just the bare minimum and it's an extremely lightweight and efficient image to use for Docker.
FROM python:3.9-alpine3.13
# Maintainer is the responsible for maintaining this Docker image. And it's best practice to define this.
# So if other people work on the project, they know who the maintainer is.
LABEL maintainer="https://github.com/HenriqueHartmann"

# This is recommend when you are running Python in a Docker Container.
# What it does, it tells Python that you don't want to buffer the output, so the output it's gonna be sent directly to the terminal.
# The output from Python will be printed directly to the console, 
# which prevents any delays of messages getting from our Python running application to the screen
# so we can see the logs immediately in the screen as they're running. 
ENV PYTHONUNBUFFERED 1

# This copies the requirements.txt file into the Docker image. We can use that to install the Python requirements.
COPY ./requirements.txt /tmp/requirements.txt

COPY ./requirements.dev.txt /tmp/requirements.txt

# We copy the app directory into the container. This directory it's going to contain our Django app.
COPY ./app /app
# We define the working directory and it's the default directory that will commands are going to be run
# from when we run commands on our Docker image. And basically set where our Django project is going to be sent.
# So, when we run the commands, we don't need to specify the full path of the Django Management Command.
WORKDIR /app
# We set to expose 8000, which says we want to expose Port 8000 from our container to our machine when we run the container.
# And what this does is it allows us to access that port on the container that's running from our image and this way we
# can connect to the Django Development Server.
EXPOSE 8000

ARG DEV=false

# Explanation about strcuture:
# Basically we run the run command. So, this runs a command on the alpine image that we are using when we we're building
# our image. The command was broken down onto one run block because we want to keep our images lightweight. Otherwise,
# it create a new image layer for every single command that we run.

# Explanation about the commands:
# The first part creates a new virtual environment that we are going to use to store our dependencies. This is not obliged
# but it just safeguards against any conflicting dependencies that may come in the base image that you're using.
# ---
# The second part we specify the full path of our virtual environment. So, we want to upgeade PIP for the virtual
# environemnt that we just created. So this upgrades the python package manager inside our virtual environment.
# ---
# The third part will install in our virtual environment all our dependencies by specifying the full path to PIP 
# to the requirements.txt file.
# ---
# The fifth part will delete our tmp directory for the purpose that we don't want any extra dependencies on our image.
# It's best practice to keep Docker Images as lightweight as possible. So, if there're any files that you don't need on the
# actual image, you want to make sure they're removed as part of your build process.
# ---
# The sixth part will call the ADD USER COMMAND, which adds a new user inside our image. So, the reason we do this is because
# it's best practice not to use the root user. If we didn't specify this bit, then the only user available inside the alpine image
# that we're using would be the the root user. In a scenario where our application get compromised, the attacker will only be able
# to do what that limited user can do. At least they don't have full access to everything in that container. So, that's why we do
# add user, we specify and disable password because we're not going to be using a password to log on to this. We do not create
# a home directory because it's not necessary and we want to keep the Docker images lightweight as possible. Finally we specify
# the name of the user.
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ $DEV = "true" ]; \
        then /py/bin/pip install - r /tmp/requirements.dev.txt ; \
    fi && \
    rm -rf /tmp && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user

# So this updates the environment variable inside the image and we're updating the path environment variable. So the path is the
# environment variable that's automatically created on Linux operating systems. So whenever we run any Python commands, it will
# run automatically from our virtual environment.
ENV PATH="/py/bin:$PATH"

# Finally we have the user line, which should be the last line of our Docker file, and this specifies the user that we're
# switching to. So until we run this line here, everything else is being done as the root user and the containers are made
# out of this image. So, we'll run using the last user that the image switched to. So, any time that you run something from this
# image, it's going to run as the django-user
USER django-user
