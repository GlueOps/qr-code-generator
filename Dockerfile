# Use an official Python runtime as a parent image
FROM python:3.11.10-alpine@sha256:65c34f59d896f939f204e64c2f098db4a4c235be425bd8f0804fd389b1e5fd80

# Copy the files into the Docker image
COPY . .

# Install dependencies
# RUN pip install --no-cache-dir fastapi uvicorn[standard] gunicorn qrcode[pil]
RUN pip install --no-cache-dir -r requirements.txt

# Make port 8000 available to the world outside this container
EXPOSE 8000

# Run the command to start uvicorn
CMD ["fastapi", "run", "qr-generator.py", "--host", "0.0.0.0", "--port", "8000"]
