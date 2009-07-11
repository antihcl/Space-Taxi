require 'physical_level'
require 'walls'
require 'parts'

class DemoLevel < PhysicalLevel
  # TODO move to actor.rb?
  TAXI_PARTS = {
    TaxiHood => :taxi_hood, 
    TaxiBlower => :taxi_blower,
    TaxiMidsection => :taxi_midsection,
    TaxiTail => :taxi_tail,
    TaxiRearsection => :taxi_rearsection,
    TaxiThruster => :taxi_thruster,
    TaxiRightThruster => :taxi_right_thruster,
    TaxiRearThruster => :taxi_rear_thruster
  }

  def setup
    space.gravity = vec2(0,100)
    @taxi = create_actor :taxi, :x => 300, :y => 350

    # TODO hrm... how to know to preload these?
    TAXI_PARTS.each do |part_class,part|
      @actor_factory.cached_actor_def part
    end

    left_wall = create_actor :left_wall, :view => false
    top_wall = create_actor :top_wall, :view => false
    right_wall = create_actor :right_wall, :view => false
    bottom_wall = create_actor :bottom_wall, :view => false
    @platform1 = create_actor :platform, :x => 300, :y => 400
    man = create_actor :man, :x => 300, :y => 367

    space.add_collision_func(:platform, :taxi) do |p,t|
      kill_taxi
    end

    space.add_collision_func(:platform, [:taxi_left_gear, :taxi_right_gear]) do |p,t|
      if @taxi.gear_down? && @taxi.can_survive? then
        @taxi.land
      else
        kill_taxi
      end

    end

    def kill_taxi
      unless @taxi.dying then
        @taxi.dying = true
        create_taxi_parts(@taxi.facing_dir)
        explosion = create_actor :particle_system, :x => @taxi.x, :y => @taxi.y
        @taxi.die
      end
    end

      @stars = []
      20.times { @stars << Ftor.new(rand(viewport.width),rand(viewport.height)) }
    end

    def draw(target, x_off, y_off)
      target.fill [25,25,25,255]
      for star in @stars
        target.draw_circle_s([star.x,star.y],1,[255,255,255,255])
      end
    end

    def create_taxi_parts(direction)
      @parts = []
      TAXI_PARTS.each do |part_class,part|
        part = create_actor part, :x => @taxi.x, :y => @taxi.y, :direction => direction
        @parts << part
      end

      @parts.last.when :remove_me do
        fire :restart_level
      end

    end

    def update(time)
      update_physics time
      director.update time

    end

end
