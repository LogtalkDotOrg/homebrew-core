class Devd < Formula
  desc "Local webserver for developers"
  homepage "https://github.com/cortesi/devd"
  url "https://github.com/cortesi/devd/archive/v0.9.tar.gz"
  sha256 "5aee062c49ffba1e596713c0c32d88340360744f57619f95809d01c59bff071f"
  license "MIT"
  head "https://github.com/cortesi/devd.git"

  bottle do
    rebuild 2
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "84be8385183d30ad91445a33da1d1d4fc30e9e74f225abeafce8993df3cfcf59"
    sha256 cellar: :any_skip_relocation, big_sur:       "9dad47b2a2c803d6ddf5a4153359a2d8e9188f37f745e964fed2a56159731597"
    sha256 cellar: :any_skip_relocation, catalina:      "89f6654470b9ef03bd42046e147f0ae372c607428f7bb934b5474f76ff397e3c"
    sha256 cellar: :any_skip_relocation, mojave:        "8806190656fd2634dadf577e7df5957b5bcaca434585f10f2a82197d8e59f03a"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "9718a2a8ec148738db0127f1dc4a0e7a1ca6c4e69d2505f02a9580230ea30b91"
  end

  depends_on "go" => :build

  def install
    ENV["GOPATH"] = buildpath
    ENV["GO111MODULE"] = "auto"
    (buildpath/"src/github.com/cortesi/devd").install buildpath.children
    cd "src/github.com/cortesi/devd" do
      system "go", "build", *std_go_args, "./cmd/devd"
    end
  end

  test do
    (testpath/"www/example.txt").write <<~EOS
      Hello World!
    EOS

    port = free_port
    fork { exec "#{bin}/devd", "--port=#{port}", "#{testpath}/www" }
    sleep 2

    output = shell_output("curl --silent 127.0.0.1:#{port}/example.txt")
    assert_equal "Hello World!\n", output
  end
end
