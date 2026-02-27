const worldNames = [
  'Nûrn',
  'Ardganor',
  'Drakmor',
  'Thaldur',
  'Eldrakis',
  'Karrûn',
  'Tholmar',
  'Torra',
  'Albia',
  'Tor',
  'Lassel',
  "Marrov'gar",
  'Planetos',
  'Ulthos',
  'Grrth',
  'Erin',
  'Nûrnheim',
  'Midkemia',
  'Skarnheim',
  'Shannara',
  'Alagaësia',
  'Syf',
  'Elysium',
  'Lankhmar',
  'Arcadia',
  'Eberron',
  'Crobuzon',
  'Valdemar',
  'Uresia',
  'Tiassa',
  'Tairnadal',
  'Solara',
  'Golarion',
  'Aerth',
  'Khand',
  'Sanctuary',
  'Thra',
  'Acheron',
  'Cosmere',
  'Tékumel',
  'Norrathal',
  'Prydain',
  'Kulthea',
  'Bas-Lag',
  'Eternia',
  'Xanth',
  'Abeir-Toril',
  'Earthsea',
  'Pern',
  'Discworld',
  'Hyboria',
  'Avalon',
  'Tyria',
  'Tarnadam',
  'Rokugan',
  'Glorantha',
  'Ivalice',
  'The World of the Five Gods',
  'Narnia',
  'Azeroth',
  'Spira',
  'Noxus',
  'Volkran',
  "Tal'Dorei",
  'Exandria',
  'Runeterra',
  'Eorzea',
  'Thraenor',
  'Xadia',
  'Roshar',
  'Teldrassil',
  'Draenor',
  'Valisthea',
  'Gensokyo',
  'Temeria',
  'Nilfgaard',
  'Aedirn',
  'Redania',
  'Kaedwen',
  'Toussaint',
  'Rivellon',
  'Lucis',
  'Gransys',
  'Drangleic',
  'Lothric',
  'Boletaria',
  'Lordran',
  'Caelid',
  'Limgrave',
  'Altus',
  'Plateauonia',
  'Iria',
  'Theros',
  'Dominaria',
  'Zendikar',
  'Innistrad',
  'Ravnica',
  'Kamigawa',
  'Lorwyn',
  'Tarkir',
  'Ikoria',
  'Strixhaven',
  'Brazenforge',
  'Solarae',
  'Ethyra',
  'Lunathor',
  'Aethernis',
  'Veydris',
  'Nytherra',
  'Astralis',
  'Zephyra',
  'Umbryss',
  'Eclipthar',
  'Skibiti Toliterium',
  'Syx',
  'Quidd'
];

let generatedChain = null;

function isVowel(char) {
  return ['a', 'e', 'i', 'o', 'u', 'y'].includes(char);
}

function calculateChain(sourceNames) {
  const chain = {};

  for (const sourceName of sourceNames) {
    const cleaned = sourceName.trim().toLowerCase();
    const basic = !/[^\u0000-\u007f]/.test(cleaned);

    for (let i = -1, syllable = ''; i < cleaned.length; i += syllable.length || 1, syllable = '') {
      const previous = cleaned[i] || '';
      let hasVowel = false;

      for (let c = i + 1; cleaned[c] && syllable.length < 5; c++) {
        const current = cleaned[c];
        const next = cleaned[c + 1];
        syllable += current;

        if (syllable === ' ' || syllable === '-') break;
        if (!next || next === ' ' || next === '-') break;

        if (isVowel(current)) hasVowel = true;

        if (current === 'y' && next === 'e') continue;
        if (basic) {
          if (current === 'o' && next === 'o') continue;
          if (current === 'e' && next === 'e') continue;
          if (current === 'a' && next === 'e') continue;
          if (current === 'c' && next === 'h') continue;
        }

        if (isVowel(current) && next === current) break;
        if (hasVowel && isVowel(cleaned[c + 2])) break;
      }

      if (!chain[previous]) {
        chain[previous] = [];
      }
      chain[previous].push(syllable);
    }
  }

  return chain;
}

function randomFrom(array) {
  return array[Math.floor(Math.random() * array.length)];
}

function validateSuffix(name, suffix) {
  if (name.endsWith(suffix)) return name;

  const firstSuffixChar = suffix.charAt(0);
  if (name.endsWith(firstSuffixChar)) {
    name = name.slice(0, -1);
  }

  const last = name.slice(-1);
  const secondLast = name.slice(-2, -1);
  if (isVowel(firstSuffixChar) === isVowel(last) && isVowel(firstSuffixChar) === isVowel(secondLast)) {
    name = name.slice(0, -1);
  }

  if (name.endsWith(firstSuffixChar)) {
    name = name.slice(0, -1);
  }

  return name + suffix;
}

function maybeAddSuffix(name) {
  const suffix = Math.random() < 0.8 ? 'ia' : 'land';
  let truncated = name;

  if (suffix === 'ia' && truncated.length > 6) {
    truncated = truncated.slice(0, 3);
  } else if (suffix === 'land' && truncated.length > 6) {
    truncated = truncated.slice(0, 5);
  }

  return validateSuffix(truncated, suffix);
}

function generateWorldName(excludeName) {
  if (!generatedChain) {
    generatedChain = calculateChain(worldNames);
  }

  const minLength = 4;
  const maxLength = 9;
  let current = randomFrom(generatedChain[''] || ['']);
  let transitions = generatedChain[''];
  let rawName = '';

  for (let i = 0; i < 20; i++) {
    if (current === '') {
      if (rawName.length < minLength) {
        current = '';
        rawName = '';
        transitions = generatedChain[''];
      } else {
        break;
      }
    } else if (rawName.length + current.length > maxLength) {
      if (rawName.length < minLength) rawName += current;
      break;
    } else {
      transitions = generatedChain[current.slice(-1)] || generatedChain[''];
    }

    rawName += current;
    current = randomFrom(transitions);
  }

  if (['\'', ' ', '-'].includes(rawName.slice(-1))) {
    rawName = rawName.slice(0, -1);
  }

  let name = [...rawName].reduce((result, char, index, chars) => {
    if (char === chars[index + 1]) return result;
    if (!result.length) return char.toUpperCase();
    if (result.slice(-1) === '-' && char === ' ') return result;
    if (result.slice(-1) === ' ' || result.slice(-1) === '-') return result + char.toUpperCase();
    if (char === 'a' && chars[index + 1] === 'e') return result;
    if (index + 2 < chars.length && char === chars[index + 1] && char === chars[index + 2]) return result;
    return result + char;
  }, '');

  if (name.split(' ').some(part => part.length < 2)) {
    name = name
      .split(' ')
      .map((part, idx) => (idx ? part.toLowerCase() : part))
      .join('');
  }

  if (name.length < 2) {
    name = randomFrom(worldNames);
  }

  if (Math.random() < 0.7) {
    name = maybeAddSuffix(name);
  }

  if (excludeName && name === excludeName) {
    return generateWorldName(excludeName);
  }

  return name;
}

export function getRandomWorldName(excludeName) {
  if (worldNames.length === 0) {
    return 'Unnamed World';
  }

  // 50/50: pick a pre-made name or synthesize one from a Markov-like chain.
  if (Math.random() < 0.5) {
    if (!excludeName || worldNames.length === 1) {
      return worldNames[Math.floor(Math.random() * worldNames.length)];
    }
    let name = worldNames[Math.floor(Math.random() * worldNames.length)];
    while (name === excludeName) {
      name = worldNames[Math.floor(Math.random() * worldNames.length)];
    }
    return name;
  }

  return generateWorldName(excludeName);
}

export { worldNames };
