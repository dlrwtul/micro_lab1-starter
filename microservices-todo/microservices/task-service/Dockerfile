FROM node:18-alpine

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

# Create the data directory
RUN mkdir -p data

EXPOSE 8082

CMD ["npm", "start"]
