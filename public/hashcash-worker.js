/**
 * Hashcash Web Worker
 *
 * This script runs on a background thread to perform the CPU-intensive
 * proof-of-work calculation without freezing the main browser UI.
 * It uses the modern Web Crypto API for fast and secure hashing.
 */

/**
 * Checks if the leading bits of a hash buffer are all zero.
 * This is the core of the proof-of-work validation.
 *
 * @param {ArrayBuffer} hashBuffer - The SHA-256 hash output.
 * @param {number} bits - The required number of leading zero bits.
 * @returns {boolean} - True if the hash meets the difficulty requirement.
 */
function checkHash(hashBuffer, bits) {
    const hashView = new DataView(hashBuffer);
    let bitsChecked = 0;

    // Check full 32-bit integers first for performance
    while (bitsChecked + 32 <= bits) {
        if (hashView.getUint32(bitsChecked / 8) !== 0) {
            return false;
        }
        bitsChecked += 32;
    }

    // Check remaining full bytes
    while (bitsChecked + 8 <= bits) {
        if (hashView.getUint8(bitsChecked / 8) !== 0) {
            return false;
        }
        bitsChecked += 8;
    }

    // Check the final remaining bits in the last relevant byte
    const remainingBits = bits - bitsChecked;
    if (remainingBits > 0) {
        const lastByte = hashView.getUint8(bitsChecked / 8);
        // Create a mask to check the most significant bits.
        // e.g., for 3 remaining bits, we check if the first 3 bits are 0.
        // The byte value must be smaller than 2^(8 - remainingBits).
        const threshold = 2 ** (8 - remainingBits);
        if (lastByte >= threshold) {
            return false;
        }
    }

    return true;
}

/**
 * Listen for a message from the main thread to start the work.
 * The message is expected to contain the stamp data.
 */
self.onmessage = async function(e) {
    const { version, bits, date, resource, extension, rand } = e.data;
    const encoder = new TextEncoder();
    let counter = 0;

    // The main hashing loop.
    // This will run continuously until a valid hash is found.
    // `crypto.subtle.digest` is async, making the loop non-blocking within the worker.
    while (true) {
        const stampStr = `${version}:${bits}:${date}:${resource}:${extension || ''}:${rand}:${counter}`;
        const data = encoder.encode(stampStr);

        // Use the browser's native SHA-256 implementation.
        const hashBuffer = await self.crypto.subtle.digest('SHA-256', data);

        if (checkHash(hashBuffer, bits)) {
            // Solution found! Send the complete stamp string back to the main thread.
            self.postMessage(stampStr);
            self.close(); // Terminate the worker as its job is done.
            return;
        }

        counter++;
    }
};
