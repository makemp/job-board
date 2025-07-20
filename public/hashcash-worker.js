/**
 * Hashcash Web Worker (with debugging)
 *
 * This script runs on a background thread to perform the CPU-intensive
 * proof-of-work calculation without freezing the main browser UI.
 */

/**
 * Checks if the leading bits of a hash buffer are all zero.
 */
// console.log('hashcash-worker.js');
function checkHash(hashBuffer, bits) {
    const hashView = new DataView(hashBuffer);
    let bitsChecked = 0;

    while (bitsChecked + 32 <= bits) {
        if (hashView.getUint32(bitsChecked / 8) !== 0) {
            return false;
        }
        bitsChecked += 32;
    }

    while (bitsChecked + 8 <= bits) {
        if (hashView.getUint8(bitsChecked / 8) !== 0) {
            return false;
        }
        bitsChecked += 8;
    }

    const remainingBits = bits - bitsChecked;
    if (remainingBits > 0) {
        const lastByte = hashView.getUint8(bitsChecked / 8);
        const threshold = 2 ** (8 - remainingBits);
        if (lastByte >= threshold) {
            return false;
        }
    }

    return true;
}

/**
 * Listen for a message from the main thread to start the work.
 */
self.onmessage = async function(e) {
    // console.log("Hashcash worker started with data:", e.data);
    const { version, bits, date, resource, extension, rand } = e.data;
    const encoder = new TextEncoder();
    let counter = 0;

    while (true) {
        const stampStr = `${version}:${bits}:${date}:${resource}:${extension || ''}:${rand}:${counter}`;
        const data = encoder.encode(stampStr);
        const hashBuffer = await self.crypto.subtle.digest('SHA-256', data);

        // --- DEBUGGING LOGS ---
        // Log progress every 10,000 attempts to see if it's working.
        // if (counter % 10000 === 0) {
        //    const hexDigest = Array.from(new Uint8Array(hashBuffer)).map(b => b.toString(16).padStart(2, '0')).join('');
        //    console.log(`Worker attempt #${counter}, hash: ${hexDigest.substring(0, 10)}...`);
        //}
        // --- END DEBUGGING ---


        if (checkHash(hashBuffer, bits)) {
            // --- DEBUGGING LOG ---
           // console.log(`%cSolution found at counter ${counter}!`, 'color: green; font-weight: bold;');
           // console.log("Sending stamp to main thread:", stampStr);
            // --- END DEBUGGING ---

            self.postMessage(stampStr);
            self.close();
            return;
        }

        counter++;
    }
};
