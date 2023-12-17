import sys
import redis
from phonemizer import phonemize

def process_chunk_and_store_in_redis(chunk, redis_client):
    phonemized_chunk = phonemize(chunk, language='fr-fr', backend='espeak')
    for original, phonemized in zip(chunk.split(), phonemized_chunk.split()):
        # Store the word and its phonemized version in Redis
        redis_client.set(original, phonemized)

def process_file(file_path, redis_client):
    with open(file_path, 'r', encoding='utf-8') as file:
        words = []
        word_count = 0

        for line in file:
            words.extend(line.strip().split())
            while len(words) >= 20:
                process_chunk_and_store_in_redis(' '.join(words[:20]), redis_client)
                words = words[20:]
                word_count += 20
                if word_count % 100 == 0:
                    print(f"Processed {word_count} words")

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
