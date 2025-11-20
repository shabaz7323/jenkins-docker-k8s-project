# Simple Node.js image
FROM node:18-alpine
WORKDIR /usr/src/app
COPY app/package.json ./
RUN npm install --production
COPY app/ ./
EXPOSE 3000
CMD ["npm", "start"]
