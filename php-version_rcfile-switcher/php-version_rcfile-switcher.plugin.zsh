# Zsh hook function to load .phpvrc files
load_phpvrc()
{
    # Current php version without patch version
    local php_current_version=$(php -r "echo PHP_VERSION;" | cut -d'.' -f 1,2)
    # Path to the .phpvrc file
    local phpvrc_path="$(php_find_phpvrc)"

    # Check if there exists a .phpvrc file
    if [ -f "$phpvrc_path" ]; then
        local php_rcfile_version=$(<${phpvrc_path})
    else
        # if not use default php version (if php-version is installed)
        if type php-version > /dev/null; then
          if [ "$php_current_version" != "${PHPVRC_DEFAULT}" ]; then
            echo "Using default PHP version: ${PHPVRC_DEFAULT}"
            php-version ${PHPVRC_DEFAULT}
          fi
        fi
        return
    fi

    # only proceed if php-version is installed
    if ! type php-version > /dev/null; then
        echo "There is an .phpvrc file but php-version isn't installed!"
        echo "If you want to use it see https://github.com/wilmoore/php-version"
        return
    fi

    # Check if the php version in .phpvrc is installed on the computer
    if [ `php-version | grep "$php_rcfile_version" | wc -l` = 0 ]; then
        # Install the php version in .phpvrc on the computer and switch to that php version
        echo "The PHP version specified in the .phpvrc file isn't installed!"
        echo "Install PHP in version: $php_rcfile_version"
        return
    fi

    # Check if the current php version matches the version in .phpvrc
    if [ "$php_rcfile_version" != "$php_current_version" ]; then
        # Switch php versions
        echo "Using PHP: $php_rcfile_version"
        php-version $php_rcfile_version
    fi
}

# functions to find .phpvrc file
php_find_phpvrc() {
  local dir
  dir="$(php_find_up '.phpvrc')"
  if [ -e "${dir}/.phpvrc" ]; then
    echo "${dir}/.phpvrc"
  fi
}
php_find_up() {
  local path_
  path_="${PWD}"
  while [ "${path_}" != "" ] && [ ! -f "${path_}/${1-}" ]; do
    path_=${path_%/*}
  done
  echo "${path_}"
}

# Automatically switch php versions when a directory has a `.phpvrc` file
autoload -U add-zsh-hook
# Add the above function when the present working directory (pwd) changes
add-zsh-hook chpwd load_phpvrc
load_phpvrc
