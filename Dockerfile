# Use the official Node.js environment as the base image
FROM node:21-alpine

# Set the working directory in the Docker container
# WORKDIR /usr/src/app

# Copy the package.json and package-lock.json to install dependencies
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of your application code
COPY . .

# Make port 80 available outside this container
EXPOSE 3000

# Run your app
CMD npm start