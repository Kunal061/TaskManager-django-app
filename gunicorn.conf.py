# Gunicorn configuration
bind = '0.0.0.0:8010'
workers = 3
timeout = 30

import multiprocessing
workers = min(4, (multiprocessing.cpu_count() * 2) + 1)

# Logging
import logging
from logging.handlers import RotatingFileHandler

loglevel = 'info'
accesslog = '-'  # send to stdout
errorlog = '-'   # send to stdout

# Optional file logging
file_handler = RotatingFileHandler('/app/logs/gunicorn.log', maxBytes=10*1024*1024, backupCount=5)
file_handler.setLevel(logging.INFO)
file_handler.setFormatter(logging.Formatter('%(asctime)s [%(levelname)s] %(message)s'))

def when_ready(server):
    try:
        # attach file handler to gunicorn logger
        server.log.access_log.addHandler(file_handler)
        server.log.error_log.addHandler(file_handler)
    except Exception:
        pass
