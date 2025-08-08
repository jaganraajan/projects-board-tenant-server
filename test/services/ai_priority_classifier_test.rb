require "test_helper"

class AiPriorityClassifierTest < ActiveSupport::TestCase
  def setup
    @classifier = AiPriorityClassifier.new
  end

  test "should return fallback priority when no API key is configured" do
    # Ensure no API key is set
    ENV['OPENAI_API_KEY'] = nil
    
    priority = AiPriorityClassifier.classify_priority(
      title: "Test task",
      description: "Test description"
    )
    
    assert_equal "Priority 2", priority
  end

  test "should handle empty title gracefully" do
    ENV['OPENAI_API_KEY'] = nil
    
    priority = AiPriorityClassifier.classify_priority(
      title: "",
      description: "Some description"
    )
    
    assert_equal "Priority 2", priority
  end

  test "should handle missing description" do
    ENV['OPENAI_API_KEY'] = nil
    
    priority = AiPriorityClassifier.classify_priority(
      title: "Important task"
    )
    
    assert_equal "Priority 2", priority
  end

  test "should fallback gracefully when API error occurs" do
    # Test that API errors are handled gracefully
    # This test verifies the error handling path works correctly
    ENV['OPENAI_API_KEY'] = 'test-key'
    
    # The API call will fail due to invalid key, but should fallback gracefully
    priority = AiPriorityClassifier.classify_priority(
      title: "Test task",
      description: "Test description"
    )
    
    # Should return fallback priority when API fails
    assert_equal "Priority 2", priority
    
    # Clean up
    ENV.delete('OPENAI_API_KEY')
  end

  test "should validate priority values in valid range" do
    valid_priorities = ["Priority 1", "Priority 2", "Priority 3", "Priority 4"]
    
    # Test each valid priority
    valid_priorities.each do |priority|
      task = Task.new(
        title: "Test", 
        status: "todo", 
        priority: priority,
        user: users(:one)
      )
      assert task.valid?, "#{priority} should be valid"
    end
  end

  test "should reject invalid priority values" do
    invalid_priorities = ["Priority 0", "Priority 5", "High", "Low"]
    
    invalid_priorities.each do |priority|
      task = Task.new(
        title: "Test", 
        status: "todo", 
        priority: priority,
        user: users(:one)
      )
      assert_not task.valid?, "#{priority} should be invalid"
      assert_includes task.errors[:priority], "is not included in the list"
    end
  end

  test "should allow blank priority values" do
    task = Task.new(
      title: "Test", 
      status: "todo", 
      priority: "",
      user: users(:one)
    )
    assert task.valid?, "Blank priority should be valid"
    
    task_nil = Task.new(
      title: "Test", 
      status: "todo", 
      priority: nil,
      user: users(:one)
    )
    assert task_nil.valid?, "Nil priority should be valid"
  end
end