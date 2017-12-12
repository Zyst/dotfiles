const { symlinkSync, mkdirSync, renameSync } = require("fs");
const { sep } = require("path");
const { homedir, platform } = require("os");

const home = homedir();

const createPath = dirArray => dirArray.join(sep);

const makeDirectory = path => {
  try {
    mkdirSync(path);

    console.log(`${path} created`);
  } catch (err) {
    if (err.code !== "EEXIST") {
      throw err;
    }

    console.log(`${path} already exists`);
  }
};

// The dir of the repository
const dir = createPath([home, "dev", "dotfiles"]);
const oldDir = [home, "dotfiles_old"];

// Folder where we will create/link MPV
const mpvFolder =
  platform() === "win32"
    ? [home, "AppData", "Roaming", "mpv"]
    : [home, ".config", "mpv"];

// Folders we will create
const folders = {
  vim: [
    [home, ".vim"],
    [home, ".vim", "undo_files"],
    [home, ".vim", "swap_files"],
    [home, ".vim", "backup_files"]
  ],
  mpv: [mpvFolder],
  backup: [oldDir]
};

const createFolders = folders => {
  console.log("Creating folders...\n");

  Object.values(folders).forEach(program => {
    program.map(createPath).forEach(makeDirectory);
  });

  console.log("\nFinished creating folders!\n");
};

createFolders(folders);

const moveItem = (path, target) => {
  try {
    renameSync(path, target);
  } catch (err) {
    if (err.code !== "ENOENT") {
      throw err;
    }

    console.log(`${path} doesn't exist yet`);
  }
};

const createSymlink = (
  target,
  path = `${home}${sep}.${target}`,
  type = "file"
) => {
  moveItem(path, `${createPath(oldDir)}${sep}.${target}`);

  symlinkSync(`${dir}${sep}${target}`, path, type);

  console.log(`Created ${path} symlink`);
};

// Files we will symlink
const files = [
  { name: "vimrc" },
  { name: "zshrc" },
  { name: "hyper.js" },
  { name: "tern-config" },
  { name: "eslintrc.js" },
  { name: "tmux.conf" },
  { name: "bashrc" },
  { name: "minttyrc" },
  {
    name: "mpv",
    path: createPath(mpvFolder),
    type: "dir"
  }
];

console.log("Creating symlinks...\n");

files.forEach(({ name, path, type }) => {
  createSymlink(name, path, type);
});

console.log("\nFinished creating symlinks!\n");
