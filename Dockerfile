FROM node:18
WORKDIR /app
COPY package.json .
RUN npm install
COPY . ./
EXPOSE 9005
CMD [ "npm","start" ]
