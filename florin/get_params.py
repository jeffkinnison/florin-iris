import json

with open('stats.json', 'r') as f:
    stats = json.load(f)

params = {}

for subject, vals in stats.items():
    paramset = {
        't_iris': vals[0][-1],
        't_pupil': vals[0][-2],
        'window_iris': [2, 256, 256],
        'window_pupil': [2, 256, 256],
    }

    if subject[:2] in '44 45 46 47 48 49 50 51 52 53 54 55 56 57'.split() or subject == '77_P_2':
        paramset['window_pupil'] = [2, 64, 64]
    elif subject[:2] == '62':
        paramset['window_pupil'] = [2, 32, 32]

    if 'P' in subject:
        subject = subject.replace('P', 'R')
    params[subject] = paramset

with open('params.json', 'w') as f:
    json.dump(params, f)
