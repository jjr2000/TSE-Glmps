def write(logStr):
    with open('log.txt', 'a') as the_file:
        the_file.write(f'{logStr}\n')

