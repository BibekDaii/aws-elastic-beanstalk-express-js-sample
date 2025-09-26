#FROM node:16
WORKDIR /app
COPY . .
RUN npm install
CMD ["node", "app.js"]
# Use official Node.js runtime as base image
FROM node:16

# Set working directory
WORKDIR /app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code
COPY . .

# Expose port (e.g., 8080 for Express default)
EXPOSE 8080

# Command to run the app
CMD ["npm", "start"]
