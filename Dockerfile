# Use an official Python runtime as a parent image
FROM python:3.11.13-alpine@sha256:a25e12e5f7bd9ce4578bc87eadec231cc3aa7d6a03723601d3e6f82639969d3a

# Copy the files into the Docker image
COPY . .

# Install dependencies
# RUN pip install --no-cache-dir fastapi uvicorn[standard] gunicorn qrcode[pil]
RUN pip install --no-cache-dir -r requirements.txt

# Make port 8000 available to the world outside this container
EXPOSE 8000

# Run the command to start uvicorn
CMD ["fastapi", "run", "qr-generator.py", "--host", "0.0.0.0", "--port", "8000"]
