#To Run
#sage particle_systems.sage
import random
from sage.plot.plot3d.shapes import *

linear_rotation = "linear rotation"
linear_attractor = "linear attractor"
linear_rotation_with_attractor = "linear rotation with attractor"
brownean = "brownean"
browneanSpherical = "browneanSpherical"

class particle(object):
    """a particle"""
    def __init__(self, **kwargs):
        self.dimensions = kwargs.get("dimensions")
        self.forcefields = kwargs.get("forcefields")
        self.color = kwargs.get("color")
        self.history = []
        for forcefield in self.forcefields:
            forcefield.register_particle(self)

    def move(self):
        self.history.append(self.dimensions)
        for field in self.forcefields:
            for dimension in self.dimensions:
                self.dimensions[dimension] = field.perturb(self.dimensions).get(dimension)

class field(object):
    """a field object"""
    def __init__(self):
        self.particles = []
        
    def deform(self):
        pass

    def register_particle(self, particle):
        self.particles.append(particle)

    def force_at_location(self, dimensions):
        return {"vx":0, "vy":0, "vz":0}

    def perturb(self, dimensions):
        newdimensions = {}
        newdimensions.update(dimensions)
        for xi, vxi in [("x","vx"), ("y","vy"), ("z", "vz")]:
            if xi in dimensions and vxi in dimensions:
                xi_new = dimensions[xi] + dimensions[vxi]
                newdimensions[xi] = xi_new
                vxi_new = dimensions[vxi]+self.force_at_location(dimensions).get(vxi)
                newdimensions[vxi] = vxi_new
        return newdimensions

class linearRotationField(field):
    """linear rotation"""
    def force_at_location(self, dimensions):
        dt = .1
        return {"vx":-dimensions.get("y")*dt, "vy":dimensions.get("x")*dt, "vz":0}

class linearRotationFieldWithAttractor(field):
    """linear rotation with attractor"""
    def force_at_location(self, dimensions):
        dt = .1
        dr = 1/(dimensions.get("x")**2+dimensions.get("y")**2)**.5
        return {"vx":(-dimensions.get("y")-2*dimensions.get("x"))*dt*dr, "vy":(dimensions.get("x")-2*dimensions.get("y"))*dt*dr, "vz":0}

class linearAttractor(field):
    """linear rotation with attractor"""
    def force_at_location(self, dimensions):
        dt = .1
        dr = 1/(dimensions.get("x")**2+dimensions.get("y")**2)**.5
        return {"vx":(-dimensions.get("x"))*dt*dr, "vy":(-dimensions.get("y"))*dt*dr, "vz":0}


class browneanField(field):
    """brownean"""
    def force_at_location(self, dimensions):
        dt = .1
        dx = random.gauss(0,1)
        dy = random.gauss(0,1)
        dz = random.gauss(0,1)
        return {"vx":dx*dt, "vy":dy*dt, "vz":dz*dt}

class browneanSphericalField(field):
    """brownean spherical"""
    def force_at_location(self, dimensions):
        dt = 0.1
        dx = random.gauss(0,1)
        dy = random.gauss(0,1)
        dz = random.gauss(0,1)
        #also need to cancel the radius by adding this: r/|r|-r
        return {"vx":dx*dt, "vy":dy*dt, "vz":dz*dt}

class flatField(field):
    """flat field"""
    pass

class forceFieldFactory(object):
    """Creates a field"""
    def __init__(self, **kwargs):
        self.forcefield_type = kwargs.get("forcefield_type")

    def newField(self):
        if self.forcefield_type == linear_rotation:
            return linearRotationField()
        if self.forcefield_type == linear_rotation_with_attractor:
            return linearRotationFieldWithAttractor()
        if self.forcefield_type == brownean:
            return browneanField()
        if self.forcefield_type == browneanSpherical:
            return browneanSphericalField()
        else:
            return flatField()

class particleFactory(object):
    def __init__(self, **kwargs):
        self.forcefields = kwargs.get("forcefields")
        self.timeout = kwargs.get("timeout")
        self.color = kwargs.get("color","blue")

    def newParticle(self):
        dimensions = {"x":random.random()*100-50, "y":random.random()*100-50, "vx":0, "vy":0, "m":1}
        return particle(dimensions=dimensions, forcefields=self.forcefields, color=self.color)
        
class particle_systems(object):
    """Shows Particle Systems"""
    particle_list = []
    field_list = []

    def visualize_frame(self):
        """Visualize a particle system"""
        frame = Graphics()
        frame3d = sage.plot.plot3d.base.Graphics3d()
        frame.axes(False)
        for particle in self.particle_list:
            x = particle.dimensions.get("x")
            y = particle.dimensions.get("y")
            z = particle.dimensions.get("z", 0)
            color=particle.color
            size = particle.dimensions.get("m")
            d = disk((x,y), size, (0, 2*pi), color=color)
            d.axes(False)
            frame += d
            sphere3d = sage.plot.plot3d.shapes2.sphere(center=(x,y,z), size=size, color=color, aspect_ratio=[1,1,1])
            frame3d += sphere3d
        frame.axes(False)
        return frame,frame3d

    def __init__(self, field_config_dict, particle_config_list):
        """Initializes an object"""
        for profile in field_config_dict:
            forcefield_type = field_config_dict.get(profile).get("forcefield_type", linear_rotation)
            force_field_factory = forceFieldFactory(forcefield_type=forcefield_type)
            forcefield = force_field_factory.newField()
            field_config_dict[profile]["forcefield"] = forcefield

        for profile in particle_config_list:
            forcefield_type_list = profile.get("forcefield_type_list")
            timeout = profile.get("timeout", 1)
            number_particles = profile.get("number_particles", 100)
            color = profile.get("color", "blue")
            forcefields = [field_config_dict.get(forcefield_type).get("forcefield") for forcefield_type in forcefield_type_list]
            particle_factory = particleFactory(forcefields=forcefields, timeout=timeout, color=color)
            for i in range(0, number_particles):
                particle = particle_factory.newParticle()
                self.particle_list.append(particle)
	
    def act(self):
        for particle in self.particle_list:
            particle.move()
        for field in self.field_list:
            field.deform()

def main():
    #plotname="test_3nov2023"
    plotname="brownean"
    forcefield_config = {linear_rotation : {"forcefield_type" : linear_rotation}, linear_attractor : {"forcefield_type" : linear_attractor}, linear_rotation_with_attractor : {"forcefield_type" : linear_rotation_with_attractor}, brownean : {"forcefield_type" : brownean}, browneanSpherical : {"forcefield_type" : browneanSpherical}}
    if plotname == "test_3nov2023":
        particle_config = [{"forcefield_type_list":[linear_rotation], "timeout":1, "number_particles":100, "color":"blue"}, {"forcefield_type_list":[linear_rotation_with_attractor], "timeout":1, "number_particles":100, "color":"blue"}, {"forcefield_type_list":[linear_attractor], "timeout":1, "number_particles":100, "color":"blue"}]
    elif plotname == "brownean":
        particle_config = [{"forcefield_type_list":[brownean], "timeout":1, "number_particles":100, "color":"green"}]
    ps = particle_systems(forcefield_config, particle_config)
    timesteps = 20
    frames = []
    frames3d=[]
    for i in range(0,timesteps):
        frame,frame3d = ps.visualize_frame()
        frame.save(f"results/{plotname}/frame_{i}.png".format(i=i), xmin=-100, xmax=100, ymin=-100, ymax=100)
        frames.append(frame)
        frame3d.save(f"results/{plotname}/frame3d_{i}.png".format(i=i), xmin=-100, xmax=100, ymin=-100, ymax=100, zmin=-100, zmax=100)
        frames3d.append(frame3d)
        ps.act()
    animate(frames,xmin=-100,xmax=100,ymin=-100,ymax=100, axes=False).save(f'results/{plotname}/plots.gif')
    animate(frames3d,xmin=-100,xmax=100,ymin=-100,vymax=100, zmin=-100, zmax=100, axes=False).save(f'results/{plotname}/plots3d.gif')
    #ps.visualize_movie(frames)

if __name__ == "__main__":
    main()
