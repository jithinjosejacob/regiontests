# Using cypress base image
FROM cypress/base:14.10.1

# Change work directory
WORKDIR /apt-agency-api-testing

# Copy required directories and files
COPY ./package.json package.json
COPY ./package-lock.json package-lock.json
COPY cypress cypress
COPY ./cypress.json cypress.json

# Install node modules
RUN npm ci

# Verify Cypress installation worked
RUN npx cypress verify