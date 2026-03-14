import json
import requests

start = 0
<<<<<<< HEAD
url = f'https://api.archives-ouvertes.fr/search/?start=12&rows=10'
=======
url = f'https://api.archives-ouvertes.fr/search/'
author_url = 'http://api.archives-ouvertes.fr/ref/authors?rows=10000'
>>>>>>> 20ccea9 (a)
response = requests.get(url)
#response_json = response.get_json()
print(response.json())
#print(f'{response.status_code}')
#timeout still responds with 200
# with open('api_response.json', 'w') as f:
#     #f.write(response.text)
#     json.dump(response.json(), f, indent=4)

if "response" in response.json():
    print('response in response')
    docs = response.json()['response']['docs']
    print(f'length of response {len(docs)}')
elif "error" in response.json():
    print('error in response')
    
# start = 40000000
# url = f'https://api.archives-ouvertes.fr/search/?&start={start}'
# response = requests.get(url)
# if "response" in response.json():
#     print('response in response')
# elif "error" in response.json():
#     print('error in response')