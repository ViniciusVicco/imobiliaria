export function buildBrokerCode(userId: string) {
  let hash = 0;
  for (const char of userId) {
    hash = (hash * 31 + char.charCodeAt(0)) % 100000;
  }

  return `SE-${hash.toString().padStart(5, '0')}`;
}
