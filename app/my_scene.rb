class MyScene < SKScene
  def initWithSize(size)
    super

    self.backgroundColor = SKColor.colorWithRed(0.102, green: 0.255, blue: 0.373, alpha: 1)
    
    self.physicsWorld.contactDelegate = self
    
    load_map
    
    @light_degrees = 0
    
    self
  end
    
  def touchesBegan(touches, withEvent: event)
    touch = touches.anyObject
    position = touch.locationInNode(self)

    select_node(position)
  end
  
  def touchesMoved(touches, withEvent: event)
    touch = touches.anyObject
    position = touch.locationInNode(self)
    previous_position = touch.previousLocationInNode(self)
    
    translation = CGPointMake(position.x - previous_position.x, position.y - previous_position.y)
    
    unless @selected_node.is_a? SKScene
      @selected_node.position = [@selected_node.position.x + translation.x, @selected_node.position.y + translation.y]
    end
  end
  
  def touchesEnded(touches, withEvent: event)
    unless @selected_node.nil?
      @selected_node.removeAllActions
    end
  end
  
  def select_node(position)
    touched_node = self.nodeAtPoint(position)
    
    unless touched_node.is_a? SKScene
      if @selected_node != touched_node
        unless @selected_node.nil?
          @selected_node.removeAllActions
          @selected_node.runAction(SKAction.rotateToAngle(0.0, duration: 0.1))
        end
      
        @selected_node = touched_node
      
        sequence = SKAction.sequence([
          SKAction.rotateByAngle(degree_to_radian(-4.0), duration: 0.1),
          SKAction.rotateByAngle(0.0, duration: 0.1),
          SKAction.rotateByAngle(degree_to_radian(4.0), duration: 0.1)
        ])
      
        @selected_node.runAction(SKAction.repeatActionForever(sequence))
      end 
    end
  end
  
  def load_map
    @categories = {
      1 => 1 << 0,
      2 => 1 << 1,
      3 => 1 << 2
    }
    
    color = SKColor.colorWithRed(0.467, green: 0.537, blue: 0.227, alpha: 1)

    obstacle_1 = SKSpriteNode.spriteNodeWithColor(color, size: [200, 20])
    obstacle_1.name = 'obstacle_1'
    obstacle_1.position = [250, 100]
    obstacle_1.physicsBody = SKPhysicsBody.bodyWithRectangleOfSize(obstacle_1.size)
    obstacle_1.physicsBody.affectedByGravity = false
    obstacle_1.physicsBody.categoryBitMask = @categories[2]
    obstacle_1.physicsBody.collisionBitMask = 0x00000000
    self.addChild(obstacle_1)

    obstacle_2 = SKSpriteNode.spriteNodeWithColor(color, size: [40, 40])
    obstacle_2.name = 'obstacle_2'
    obstacle_2.position = [400, 200]
    obstacle_2.physicsBody = SKPhysicsBody.bodyWithRectangleOfSize(obstacle_2.size)
    obstacle_2.physicsBody.affectedByGravity = false
    obstacle_2.physicsBody.categoryBitMask = @categories[2]
    obstacle_2.physicsBody.collisionBitMask = 0x00000000
    self.addChild(obstacle_2)

    obstacle_3 = SKSpriteNode.spriteNodeWithColor(color, size: [50, 20])
    obstacle_3.name = 'obstacle_3'
    obstacle_3.position = [60, 60]
    obstacle_3.physicsBody = SKPhysicsBody.bodyWithRectangleOfSize(obstacle_3.size)
    obstacle_3.physicsBody.affectedByGravity = false
    obstacle_3.physicsBody.categoryBitMask = @categories[2]
    obstacle_3.physicsBody.collisionBitMask = 0x00000000
    self.addChild(obstacle_3)
    
    light = SKSpriteNode.spriteNodeWithColor(SKColor.colorWithRed(1.000, green: 0.980, blue: 0.294, alpha: 1), size: [10, 10])
    light.name = 'light'
    light.position = [self.size.width / 2, self.size.height / 2]
    
    ray = SKShapeNode.node
    ray.name = "ray"
    path_to_draw = CGPathCreateMutable()
    CGPathMoveToPoint(path_to_draw, nil, 0, 0)
    CGPathAddLineToPoint(path_to_draw, nil, 600, 0)
    ray.path = path_to_draw
    ray.setStrokeColor(SKColor.yellowColor)
    ray.setLineWidth(0.2)

    light.addChild(ray)
    
    self.addChild(light)
    
  end
    
  def degree_to_radian(degree)
    degree / 180.0 * Math::PI
  end
  
  def update(current_time)
    @last_update_time ||= current_time
    
    time_delta = current_time - @last_update_time
    @light_degrees += 36 * time_delta
    
    if @light_degrees > 360
      @light_degrees = @light_degrees - 360
    end
    
    light = self.childNodeWithName('light')
    light.zRotation = degree_to_radian(@light_degrees)
        
    @last_update_time = current_time
    
    # Chequeamos si hay colisión en la dirección del rayo
    # Primero obtenemos coordenadas de start y end del rayo
    ray_start = self.convertPoint(light.position, fromNode: light)
    ray_end = [
      600 * Math::cos(@light_degrees),
      600 * Math::sin(@light_degrees)
    ]

    self.physicsWorld.enumerateBodiesAlongRayStart(ray_start, end: ray_end,
      usingBlock: lambda { |body, point, normal, stop|
        puts "#{point.x}, #{point.y}"
        # stop = true
      }
    )
    
  end
  
end