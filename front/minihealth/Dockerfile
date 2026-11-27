#<<<<<<< HEAD
FROM node:22-alpine AS build
#=======
#FROM docker.io/library/node:22-alpine AS build
#>>>>>>> main
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY index.html vite.config.js ./
COPY src ./src
RUN npm run build

#<<<<<<< HEAD
FROM nginx:1.30-alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist /usr/share/nginx/html
#=======
#FROM docker.io/library/nginx:1.30-alpine
#COPY nginx.conf /etc/nginx/conf.d/default.conf
#COPY --from=build /app/dist/ /usr/share/nginx/html/
#>>>>>>> main
