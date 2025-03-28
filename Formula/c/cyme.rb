class Cyme < Formula
  desc "List system USB buses and devices"
  homepage "https://github.com/tuna-f1sh/cyme"
  url "https://github.com/tuna-f1sh/cyme/archive/refs/tags/v2.1.2.tar.gz"
  sha256 "c79f2ee7abfd93b313ae464906801eab2974f14a4f8133c44c3454c25a12df5f"
  license "GPL-3.0-or-later"
  head "https://github.com/tuna-f1sh/cyme.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "f9460a7f4c1ce1c8c3ec689d5640b25814457a5a549f138071fbe056b5b2202e"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "dd4d14f6550b077d1970615fac39a52898c194a7ddc91b0f72b21b46cf1fc154"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "ff8f29b0c7c7d9cde0ecf72645c9539c6989bb25ccbc78f771d2512b0d36def6"
    sha256 cellar: :any_skip_relocation, sonoma:        "655fefb9e28cf371c9f69eb0e81855bbace8e8ab7244533d4223102f72ddf462"
    sha256 cellar: :any_skip_relocation, ventura:       "6a21baa067354074899e99552d724cbb5c3147ef239ccb03c04dde31440536b4"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "017617563ba7d77ec7c5fb6f0300a347e4ec995f2f0552b3b3ed533e3f21d548"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "928779ea652db2b1c9e45bae7179b9010759ccd888d5f7d8dade42e5225a36ad"
  end

  depends_on "rust" => :build
  depends_on "libusb"

  def install
    system "cargo", "install", *std_cargo_args
    man1.install "doc/cyme.1"
    bash_completion.install "doc/cyme.bash" => "cyme"
    zsh_completion.install "doc/_cyme"
    fish_completion.install "doc/cyme.fish"
  end

  test do
    # Test fails on headless CI
    return if OS.linux? && ENV["HOMEBREW_GITHUB_ACTIONS"]

    output = JSON.parse(shell_output("#{bin}/cyme --tree --json"))
    assert_predicate output["buses"], :present?
  end
end
