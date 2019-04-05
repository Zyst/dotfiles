const {
  symlinkSync,
  mkdirSync,
  renameSync,
  existsSync,
  readdirSync,
  lstatSync,
  unlinkSync,
  rmdirSync
} = require('fs');
const { sep } = require('path');
const { homedir, platform } = require('os');

const home = homedir();

const createPath = dirArray => dirArray.join(sep);

const makeDirectory = path => {
  try {
    mkdirSync(path);

    console.log(`${path} created`);
  } catch (err) {
    if (err.code !== 'EEXIST') {
      throw err;
    }

    console.log(`${path} already exists`);
  }
};

// The dir of the repository
const dir = createPath([home, 'dev', 'dotfiles']);
const oldDir = [home, 'dotfiles_old'];

// Folder where we will create/link MPV
const mpvFolder =
  platform() === 'win32'
    ? [home, 'AppData', 'Roaming', 'mpv']
    : [home, '.config', 'mpv'];

const alacrittyFolder =
  platform() === 'win32'
    ? [home, 'AppData', 'Roaming', 'alacritty']
    : [home, '.config', 'alacritty'];

const getShitDoneFolder = [home, '.config'];
const emacsFolder = [home, '.emacs.d'];

// Folders we will create
const folders = {
  vim: [
    [home, '.vim'],
    [home, '.vim', 'undo_files'],
    [home, '.vim', 'swap_files'],
    [home, '.vim', 'backup_files']
  ],
  mpv: [mpvFolder],
  backup: [oldDir],
  getShitDone: [getShitDoneFolder],
  emacs: [emacsFolder],
  alacritty: [alacrittyFolder]
};

const deleteFolderRecursive = path => {
  if (existsSync(path)) {
    readdirSync(path).forEach(file => {
      const curPath = `${path}${sep}${file}`;

      if (lstatSync(curPath).isDirectory()) {
        // recurse
        deleteFolderRecursive(curPath);
      } else {
        // delete file
        unlinkSync(curPath);
      }
    });

    rmdirSync(path);
  }
};

deleteFolderRecursive(createPath(oldDir));

const createFolders = folders => {
  console.log('Creating folders...\n');

  Object.values(folders).forEach(program => {
    program.map(createPath).forEach(makeDirectory);
  });

  console.log('\nFinished creating folders!\n');
};

createFolders(folders);

const moveItem = (path, target) => {
  try {
    renameSync(path, target);
  } catch (err) {
    if (err.code === 'EPERM') {
      // If I ever have more than one folder I symlink I promise I'll write
      // code to delete folders recursively. But in the meantime this will do.
      throw new Error(
        `Can't move ${path} to ${target}. Try removing both folders and try running this script again`
      );
    }

    if (err.code !== 'ENOENT') {
      throw err;
    }

    console.log(`${path} doesn't exist yet`);
  }
};

const createSymlink = ({
  name,
  path = `${home}${sep}.${name}`,
  type = 'file',
  dotfile = true
}) => {
  moveItem(path, `${createPath(oldDir)}${sep}${dotfile ? '.' : ''}${name}`);

  symlinkSync(`${dir}${sep}${name}`, path, type);

  console.log(`Created ${path} symlink`);
};

// Files we will symlink
const files = [
  { name: 'vimrc' },
  { name: 'zshrc' },
  { name: 'hyper.js' },
  { name: 'tern-config' },
  { name: 'eslintrc.js' },
  { name: 'tmux.conf' },
  { name: 'bashrc' },
  { name: 'minttyrc' },
  {
    name: 'mpv',
    path: createPath(mpvFolder),
    type: 'dir'
  },
  {
    name: '.config',
    path: createPath(getShitDoneFolder),
    type: 'dir'
  },
  {
    name: '.emacs.d',
    path: createPath(emacsFolder),
    type: 'dir'
  },
  {
    name: 'alacritty.yml',
    path: createPath([...alacrittyFolder, 'alacritty.yml'])
  }
];

console.log('Creating symlinks...\n');

files.forEach(createSymlink);

console.log('\nFinished creating symlinks!');
