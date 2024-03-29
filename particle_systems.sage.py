

# This file was *autogenerated* from the file particle_systems.sage
from sage.all_cmdline import *   # import sage library

_sage_const_0 = Integer(0); _sage_const_p1 = RealNumber('.1'); _sage_const_1 = Integer(1); _sage_const_2 = Integer(2); _sage_const_p5 = RealNumber('.5'); _sage_const_0p1 = RealNumber('0.1'); _sage_const_100 = Integer(100); _sage_const_50 = Integer(50); _sage_const_20 = Integer(20)#To Run
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
        return {"vx":_sage_const_0 , "vy":_sage_const_0 , "vz":_sage_const_0 }

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
        dt = _sage_const_p1 
        return {"vx":-dimensions.get("y")*dt, "vy":dimensions.get("x")*dt, "vz":_sage_const_0 }

class linearRotationFieldWithAttractor(field):
    """linear rotation with attractor"""
    def force_at_location(self, dimensions):
        dt = _sage_const_p1 
        dr = _sage_const_1 /(dimensions.get("x")**_sage_const_2 +dimensions.get("y")**_sage_const_2 )**_sage_const_p5 
        return {"vx":(-dimensions.get("y")-_sage_const_2 *dimensions.get("x"))*dt*dr, "vy":(dimensions.get("x")-_sage_const_2 *dimensions.get("y"))*dt*dr, "vz":_sage_const_0 }

class linearAttractor(field):
    """linear rotation with attractor"""
    def force_at_location(self, dimensions):
        dt = _sage_const_p1 
        dr = _sage_const_1 /(dimensions.get("x")**_sage_const_2 +dimensions.get("y")**_sage_const_2 )**_sage_const_p5 
        return {"vx":(-dimensions.get("x"))*dt*dr, "vy":(-dimensions.get("y"))*dt*dr, "vz":_sage_const_0 }


class browneanField(field):
    """brownean"""
    def force_at_location(self, dimensions):
        dt = _sage_const_p1 
        dx = random.gauss(_sage_const_0 ,_sage_const_1 )
        dy = random.gauss(_sage_const_0 ,_sage_const_1 )
        dz = random.gauss(_sage_const_0 ,_sage_const_1 )
        return {"vx":dx*dt, "vy":dy*dt, "vz":dz*dt}

class browneanSphericalField(field):
    """brownean spherical"""
    def force_at_location(self, dimensions):
        dt = _sage_const_0p1 
        dx = random.gauss(_sage_const_0 ,_sage_const_1 )
        dy = random.gauss(_sage_const_0 ,_sage_const_1 )
        dz = random.gauss(_sage_const_0 ,_sage_const_1 )
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
        dimensions = {"x":random.random()*_sage_const_100 -_sage_const_50 , "y":random.random()*_sage_const_100 -_sage_const_50 , "vx":_sage_const_0 , "vy":_sage_const_0 , "m":_sage_const_1 }
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
            z = particle.dimensions.get("z", _sage_const_0 )
            color=particle.color
            size = particle.dimensions.get("m")
            d = disk((x,y), size, (_sage_const_0 , _sage_const_2 *pi), color=color)
            d.axes(False)
            frame += d
            sphere3d = sage.plot.plot3d.shapes2.sphere(center=(x,y,z), size=size, color=color, aspect_ratio=[_sage_const_1 ,_sage_const_1 ,_sage_const_1 ])
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
            timeout = profile.get("timeout", _sage_const_1 )
            number_particles = profile.get("number_particles", _sage_const_100 )
            color = profile.get("color", "blue")
            forcefields = [field_config_dict.get(forcefield_type).get("forcefield") for forcefield_type in forcefield_type_list]
            particle_factory = particleFactory(forcefields=forcefields, timeout=timeout, color=color)
            for i in range(_sage_const_0 , number_particles):
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
        particle_config = [{"forcefield_type_list":[linear_rotation], "timeout":_sage_const_1 , "number_particles":_sage_const_100 , "color":"blue"}, {"forcefield_type_list":[linear_rotation_with_attractor], "timeout":_sage_const_1 , "number_particles":_sage_const_100 , "color":"blue"}, {"forcefield_type_list":[linear_attractor], "timeout":_sage_const_1 , "number_particles":_sage_const_100 , "color":"blue"}]
    elif plotname == "brownean":
        particle_config = [{"forcefield_type_list":[brownean], "timeout":_sage_const_1 , "number_particles":_sage_const_100 , "color":"green"}]
    ps = particle_systems(forcefield_config, particle_config)
    timesteps = _sage_const_20 
    frames = []
    frames3d=[]
    for i in range(_sage_const_0 ,timesteps):
        frame,frame3d = ps.visualize_frame()
        frame.save(f"results/{plotname}/frame_{i}.png".format(i=i), xmin=-_sage_const_100 , xmax=_sage_const_100 , ymin=-_sage_const_100 , ymax=_sage_const_100 )
        frames.append(frame)
        frame3d.save(f"results/{plotname}/frame3d_{i}.png".format(i=i), xmin=-_sage_const_100 , xmax=_sage_const_100 , ymin=-_sage_const_100 , ymax=_sage_const_100 , zmin=-_sage_const_100 , zmax=_sage_const_100 )
        frames3d.append(frame3d)
        ps.act()
    animate(frames,xmin=-_sage_const_100 ,xmax=_sage_const_100 ,ymin=-_sage_const_100 ,ymax=_sage_const_100 , axes=False).save(f'results/{plotname}/plots.gif')
    animate(frames3d,xmin=-_sage_const_100 ,xmax=_sage_const_100 ,ymin=-_sage_const_100 ,vymax=_sage_const_100 , zmin=-_sage_const_100 , zmax=_sage_const_100 , axes=False).save(f'results/{plotname}/plots3d.gif')
    #ps.visualize_movie(frames)

if __name__ == "__main__":
    main()

