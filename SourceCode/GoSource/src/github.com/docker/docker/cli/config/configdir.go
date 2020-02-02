package config // import "github.com/docker/docker/cli/config"

import (
	"os"
	"path/filepath"

	"github.com/docker/docker/pkg/homedir"
)

var (
	configDir     = os.Getenv("DOCKER_CONFIG")
	configFileDir = ".docker"
)

// Dir将路径返回到由DOCKER_CONFIG环境变量指定的配置目录。如果未设置DOCKER_CONFIG，则Dir返回〜/ .docker。
// Dir忽略XDG_CONFIG_HOME（与docker客户端相同）。
// TODO: this was copied from cli/config/configfile and should be removed once cmd/dockerd moves
func Dir() string {
	return configDir
}

func init() {
	if configDir == "" {
		configDir = filepath.Join(homedir.Get(), configFileDir)
	}
}
