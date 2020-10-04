"""
This Python script is responsible for executing the web requests.
Each request is dictated by the flag received.

TODO: Add the ability to refresh token
"""
import sys
import os
import json
import requests
from datetime import date

"""
HELPERS
"""


def write_json(data):
    with open(os.path.dirname(os.path.abspath(__file__)) + '/config.json', 'w') as outfile:
        json.dump(data, outfile)


"""
REQUESTS
"""


def hello(flags, configs):
    """
    This function is called as an initial setup.
     - Checks if the client_id and client_secret have already been set (if not, exits as 10)
     - Checks if the access_token has already been set (if not, exits as 11)
     - Checks if there is a need to refresh the token (automaticly refreshes and exits as 0)
    """
    if len(configs['client_id']) != 64 or len(configs['client_secret']) != 64:
        sys.exit(10)

    if 'access_token' not in configs or len(configs['access_token']) == 64:
        sys.exit(11)

    # TODO Refresh token
    sys.exit(0)


def code(flags, configs):
    """ Generate the code """
    res = requests.post('https://api.trakt.tv/oauth/device/code', json={'client_id': configs['client_id']})

    configs['device_code'] = res.json()['device_code']
    write_json(configs)

    print(res.json()['user_code'], end='')


def auth(flags, configs):
    """ Authenticate """
    res = requests.post('https://api.trakt.tv/oauth/device/token', json={
        'client_id': configs['client_id'],
        'client_secret': configs['client_secret'],
        'code': configs['device_code']
    })

    res_json = res.json()

    if 'access_token' in res_json:
        # Success
        configs['access_token'] = res_json['access_token']
        configs['refresh_token'] = res_json['refresh_token']
        del configs['device_code']
        configs['today'] = str(date.today())
        write_json(configs)
        sys.exit(0)

    sys.exit(-1)


def query(flags, configs):
    print('NOT YET IMPLEMENTED')


def get_episode(flags, configs):
    print('NOT YET IMPLEMENTED')


def checkin(flags, configs):
    print('NOT YET IMPLEMENTED')


"""
MAIN
"""


def main():
    # Get the configs
    try:
        f = open(os.path.dirname(os.path.abspath(__file__)) + '/config.json', 'r')
        data = json.load(f)
    except:
        sys.exit(10)

    # Choose what to do
    switch = {
        '--hello': hello,
        '--query': query,
        '--episode': get_episode,
        '--checkin': checkin,
        '--code': code,
        '--auth': auth
    }

    if sys.argv[1] in switch:
        switch[sys.argv[1]](sys.argv, data)
    else:
        sys.exit(-1)


if __name__ == "__main__":
    main()
