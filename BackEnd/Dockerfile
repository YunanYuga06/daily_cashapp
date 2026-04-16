FROM node:18

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

# 🔥 ini yang penting
RUN npx prisma generate

EXPOSE 8080

CMD ["nodemon ."]