require "claws"

module ClawsHelper
  def load_detection
    detection = described_class.new(configuration: detection_config)
    @app = Claws::Application.new
    @app.load_detection(detection)
  end

  def analyze(input_yaml)
    @app.analyze("workflow.yml", input_yaml)
  end

  def detection_config
    return configuration if defined? configuration

    {}
  end
end
