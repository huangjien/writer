ARG SUPABASE_URL
ARG SUPABASE_ANON_KEY
FROM nginx:alpine
COPY build/web /usr/share/nginx/html
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 8080
CMD ["nginx","-g","daemon off;"]
