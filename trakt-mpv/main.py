"""
This Python script is responsible for executing the web requests.
Each request is dictated by the flag received.

TODO: Add the ability to refresh token
"""
import sys
import os
import json

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
    print('NOT YET IMPLEMENTED')


def auth(flags, configs):
    print('NOT YET IMPLEMENTED')


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
