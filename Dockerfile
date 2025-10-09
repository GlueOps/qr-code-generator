# Use an official Python runtime as a parent image
FROM python:3.13.8-alpine@sha256:7466fcadc01effec6ae9b26f147673090a9828a16ecd7cfa5898855e3bbf12db

# Copy the files into the Docker image
COPY . .

# Install dependencies
# RUN pip install --no-cache-dir fastapi uvicorn[standard] gunicorn qrcode[pil]
RUN pip install --no-cache-dir -r requirements.txt

# Make port 8000 available to the world outside this container
EXPOSE 8000

# Run the command to start uvicorn
CMD ["fastapi", "run", "qr-generator.py", "--host", "0.0.0.0", "--port", "8000"]
