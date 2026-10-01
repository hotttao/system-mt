# First stage: Use quant_vision as the builder
FROM quant_vision:1.0.1 as builder
FROM anomaly_vision:1.0.1 as anomaly

# Second stage: Use the official Nginx image as the base image
FROM nginx:latest

# Copy the contents of /app/dist from the builder stage to the Nginx image
COPY --from=builder /app/dist /usr/share/nginx/html
COPY --from=anomaly /app/dist /usr/share/nginx/html/anomaly

# Copy the Nginx configuration file
COPY conf.d/default.conf /etc/nginx/conf.d/default.conf
