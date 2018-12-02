#!/usr/bin/python
# Simple website monitor.

# Import modules
import requests
# Variables 
website = "https://matthewdavidson.us"

try:
    r = requests.head(website)
    print(r.status_code)
    # prints the int of the status code.
except requests.ConnectionError:
    print("failed to connect")
    # Send a text alert. Change key and phone number.
    requests.post('https://textbelt.com/text', {
        'phone': '1234567890',
        'message': 'Hello world',
        'key': 'textbelt',
    })
