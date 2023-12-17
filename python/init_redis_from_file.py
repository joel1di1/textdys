import sys
import redis
from phonemizer import phonemize

def process_chunk_and_store_in_redis(chunk, redis_client):
    # print(f'Processing chunk: {chunk}')
    # keep only words that are not already in Redis
    # chunk = ' '.join([word for word in chunk.split() if not redis_client.exists(word)])

    # # print(f'\treal chunk: {chunk}')

    # #if chunk empty, return
    # if not chunk:
    #     return

    phonemized_chunk = phonemize(chunk, language='fr-fr', backend='espeak')
    for original, phonemized in zip(chunk.split(), phonemized_chunk.split()):
        # Store the word and its phonemized version in Redis
        redis_client.set(original, phonemized)

def process_file(file_path, redis_client):
    with open(file_path, 'r', encoding='utf-8') as file:
        words = []
        word_count = 0
        lines_count = 0

        # take the words at least 100 by 100
        for line in file:
            words += line.split()
            word_count += len(words)
            lines_count += 1
            if word_count >= 50:
                process_chunk_and_store_in_redis(' '.join(words), redis_client)
                words = []
                word_count = 0

            if lines_count % 1000 == 0:
                print(f'{lines_count} lines processed, last: {line}')

        # Process any remaining words
        if words:
            process_chunk_and_store_in_redis(' '.join(words), redis_client)

def main():
    if len(sys.argv) < 2:
        print("Usage: python script.py <file_path>")
        sys.exit(1)

    file_path = sys.argv[1]
    redis_client = redis.Redis(host='localhost', port=6379, db=0)
    process_file(file_path, redis_client)

if __name__ == '__main__':
    main()
