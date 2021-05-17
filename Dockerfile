FROM ubuntu:18.04

# /dev/null is used just to suppress the output 
RUN apt update > /dev/null
RUN apt install -y python3 > /dev/null

# Create a folder to store the app files
RUN mkdir /home/app && cd /home/app

# Copy the web build folder into the container
COPY build/web .

# Expose the port 8080 for use 
EXPOSE 8080

# Run a python server to serve the app
ENTRYPOINT python3 -m http.server 8080