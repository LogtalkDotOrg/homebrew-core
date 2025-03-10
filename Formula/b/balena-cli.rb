class BalenaCli < Formula
  desc "Command-line tool for interacting with the balenaCloud and balena API"
  homepage "https://docs.balena.io/reference/balena-cli/latest/"
  url "https://registry.npmjs.org/balena-cli/-/balena-cli-20.2.10.tgz"
  sha256 "fc01322b2ec3d3a8c08ca8314bab5d932fabfc206ea509dd5f2c8f5c07be8bd3"
  license "Apache-2.0"

  livecheck do
    url "https://registry.npmjs.org/balena-cli/latest"
    regex(/["']version["']:\s*?["']([^"']+)["']/i)
  end

  bottle do
    sha256                               arm64_sequoia: "b984c44c6292acc93367f6e0cc6bb9a062a16c488924e79219d4bdbb126e6038"
    sha256                               arm64_sonoma:  "5d90a2edf4ef46b04c072c6f0de82ab8deeefb9896977e035c16dff50b09702e"
    sha256                               arm64_ventura: "1c22c2be2bd1c4a903b247fbea33153fe21cdfe3dd980c75af9e05d1cbb1a6d3"
    sha256                               sonoma:        "79c6263745368cc867ec810f3d0e69d86d7edebdef9877d163923be51af1dea4"
    sha256                               ventura:       "3899ce259a789a62a495c6a3d7076a4ba054b4bbb8aa9452051fc01e64d5c335"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "98b2d750903f8fa1d30dc18cc22d2eb797e77f467ea1c47f4b059b951d4b6706"
  end

  # need node@20, and also align with upstream, https://github.com/balena-io/balena-cli/blob/master/.github/actions/publish/action.yml#L21
  depends_on "node@20"

  on_linux do
    depends_on "libusb"
    depends_on "systemd" # for libudev
    depends_on "xz" # for liblzma
  end

  def install
    ENV.deparallelize

    system "npm", "install", *std_npm_args
    bin.install_symlink libexec.glob("bin/*")

    # Remove incompatible pre-built binaries
    os = OS.kernel_name.downcase
    arch = Hardware::CPU.intel? ? "x64" : Hardware::CPU.arch.to_s
    node_modules = libexec/"lib/node_modules/balena-cli/node_modules"
    node_modules.glob("{ffi-napi,ref-napi}/prebuilds/*")
                .each { |dir| rm_r(dir) if dir.basename.to_s != "#{os}-#{arch}" }

    rm_r(node_modules/"lzma-native/build")
    rm_r(node_modules/"usb") if OS.linux?

    # Replace universal binaries with native slices
    deuniversalize_machos
  end

  test do
    assert_match "Logging in to balena-cloud.com",
      shell_output("#{bin}/balena login --credentials --email johndoe@gmail.com --password secret 2>/dev/null", 1)
  end
end
