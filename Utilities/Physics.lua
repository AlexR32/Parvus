--[[
	lua-polynomials is a Lua module created by piqey
	(John Kushmer) for finding the roots of second-,
	third- and fourth- degree polynomials.
--]]

--[[
	Just decorating our package for any programmers
	that might possibly be snooping around in here;
	you know, trying to understand and harness the
	potential of all the black magic that's been
	packed in here (you can thank Cardano's formula
	and Ferrari's method for all of that).
--]]

--__VERSION = "1.0.0" -- https://semver.org/
--__DESCRIPTION = "Methods for finding the roots of traditional- and higher-degree polynomials (2nd to 4th)."
--__URL = "https://github.com/piqey/lua-polynomials"
--__LICENSE = "GNU General Public License, version 3"

-- Utility functions

local eps = 1e-09 -- definitely small enough (0.000000001)

-- checks if d is close enough to 0 to be considered 0 (for our purposes)
local function isZero(d)
	return (d > -eps and d < eps)
end

-- fixes an issue with math.pow that returns nan when the result should be a real number
local function cuberoot(x)
	return (x > 0) and math.pow(x, (1 / 3)) or -math.pow(math.abs(x), (1 / 3))
end

--[[
	solveQuadric(number a, number b, number c)
	returns number s0, number s1

	Will return nil for roots that do not exist.

	Solves for the roots of quadric/quadratic polynomials of the following form:
	ax^2 + bx + c = 0
--]]

local function solveQuadric(c0, c1, c2)
	local s0, s1

	local p, q, D

	-- x^2 + px + q = 0
	p = c1 / (2 * c0)
	q = c2 / c0

	D = p * p - q

	if isZero(D) then
		s0 = -p
		return s0
	elseif (D < 0) then
		return
	else -- if (D > 0)
		local sqrt_D = math.sqrt(D)

		s0 = sqrt_D - p
		s1 = -sqrt_D - p
		return s0, s1
	end
end

--[[
	solveCubic(number a, number b, number c, number d)
	returns number s0, number s1, number s2

	Will return nil for roots that do not exist.

	Solves for the roots of cubic polynomials of the following form:
	ax^3 + bx^2 + cx + d = 0
--]]

local function solveCubic(c0, c1, c2, c3)
	local s0, s1, s2

	local num, sub
	local A, B, C
	local sq_A, p, q
	local cb_p, D

	-- normal form: x^3 + Ax^2 + Bx + C = 0
	A = c1 / c0
	B = c2 / c0
	C = c3 / c0

	-- substitute x = y - A/3 to eliminate quadric term: x^3 + px + q = 0
	sq_A = A * A
	p = (1 / 3) * (-(1 / 3) * sq_A + B)
	q = 0.5 * ((2 / 27) * A * sq_A - (1 / 3) * A * B + C)

	-- use Cardano's formula
	cb_p = p * p * p
	D = q * q + cb_p

	if isZero(D) then
		if isZero(q) then -- one triple solution
			s0 = 0
			num = 1
			--return s0
		else -- one single and one double solution
			local u = cuberoot(-q)
			s0 = 2 * u
			s1 = -u
			num = 2
			--return s0, s1
		end
	elseif (D < 0) then -- Casus irreducibilis: three real solutions
		local phi = (1 / 3) * math.acos(-q / math.sqrt(-cb_p))
		local t = 2 * math.sqrt(-p)

		s0 = t * math.cos(phi)
		s1 = -t * math.cos(phi + math.pi / 3)
		s2 = -t * math.cos(phi - math.pi / 3)
		num = 3
		--return s0, s1, s2
	else -- one real solution
		local sqrt_D = math.sqrt(D)
		local u = cuberoot(sqrt_D - q)
		local v = -cuberoot(sqrt_D + q)

		s0 = u + v
		num = 1

		--return s0
	end

	-- resubstitute
	sub = (1 / 3) * A

	if (num > 0) then s0 = s0 - sub end
	if (num > 1) then s1 = s1 - sub end
	if (num > 2) then s2 = s2 - sub end

	return s0, s1, s2
end

--[[
	solveQuartic(number a, number b, number c, number d, number e)
	returns number s0, number s1, number s2, number s3

	Will return nil for roots that do not exist.

	Solves for the roots of quartic polynomials of the form:
	ax^4 + bx^3 + cx^2 + dx + e = 0
--]]

local function solveQuartic(c0, c1, c2, c3, c4)
	local s0, s1, s2, s3

	local coeffs = {}
	local z, u, v, sub
	local A, B, C, D
	local sq_A, p, q, r
	local num

	-- normal form: x^4 + Ax^3 + Bx^2 + Cx + D = 0
	A = c1 / c0
	B = c2 / c0
	C = c3 / c0
	D = c4 / c0

	-- substitute x = y - A/4 to eliminate cubic term: x^4 + px^2 + qx + r = 0
	sq_A = A * A
	p = -0.375 * sq_A + B
	q = 0.125 * sq_A * A - 0.5 * A * B + C
	r = -(3 / 256) * sq_A * sq_A + 0.0625 * sq_A * B - 0.25 * A * C + D

	if isZero(r) then
		-- no absolute term: y(y^3 + py + q) = 0
		coeffs[3] = q
		coeffs[2] = p
		coeffs[1] = 0
		coeffs[0] = 1

		local results = {solveCubic(coeffs[0], coeffs[1], coeffs[2], coeffs[3])}
		num = #results
		s0, s1, s2 = results[1], results[2], results[3]
	else
		-- solve the resolvent cubic …
		coeffs[3] = 0.5 * r * p - 0.125 * q * q
		coeffs[2] = -r
		coeffs[1] = -0.5 * p
		coeffs[0] = 1

		s0, s1, s2 = solveCubic(coeffs[0], coeffs[1], coeffs[2], coeffs[3])

		-- … and take the one real solution …
		z = s0

		-- … to build two quadric equations
		u = z * z - r
		v = 2 * z - p

		if isZero(u) then
			u = 0
		elseif (u > 0) then
			u = math.sqrt(u)
		else
			return
		end

		if isZero(v) then
			v = 0
		elseif (v > 0) then
			v = math.sqrt(v)
		else
			return
		end

		coeffs[2] = z - u
		coeffs[1] = q < 0 and -v or v
		coeffs[0] = 1

		do
			local results = {solveQuadric(coeffs[0], coeffs[1], coeffs[2])}
			num = #results
			s0, s1 = results[1], results[2]
		end

		coeffs[2] = z + u
		coeffs[1] = q < 0 and v or -v
		coeffs[0] = 1

		if (num == 0) then
			local results = {solveQuadric(coeffs[0], coeffs[1], coeffs[2])}
			num = num + #results
			s0, s1 = results[1], results[2]
		end

		if (num == 1) then
			local results = {solveQuadric(coeffs[0], coeffs[1], coeffs[2])}
			num = num + #results
			s1, s2 = results[1], results[2]
		end

		if (num == 2) then
			local results = {solveQuadric(coeffs[0], coeffs[1], coeffs[2])}
			num = num + #results
			s2, s3 = results[1], results[2]
		end
	end

	-- resubstitute
	sub = 0.25 * A

	if (num > 0) then s0 = s0 - sub end
	if (num > 1) then s1 = s1 - sub end
	if (num > 2) then s2 = s2 - sub end
	if (num > 3) then s3 = s3 - sub end

	--return s0, s1, s2, s3
	--return s3, s2, s1, s0
	return {s3, s2, s1, s0}
end

local module = {}

function module.SolveTrajectory(origin, targetPosition, targetVelocity, projectileSpeed, gravity, gravityCorrection)
	gravity = gravity or workspace.Gravity
	gravityCorrection = gravityCorrection or 2

	local delta = targetPosition - origin
	gravity = -gravity / gravityCorrection

	local solutions = solveQuartic(
		gravity * gravity,
		-2 * targetVelocity.Y * gravity,
		targetVelocity.Y * targetVelocity.Y - 2 * delta.Y * gravity - projectileSpeed * projectileSpeed + targetVelocity.X * targetVelocity.X + targetVelocity.Z * targetVelocity.Z,
		2 * delta.Y * targetVelocity.Y + 2 * delta.X * targetVelocity.X + 2 * delta.Z * targetVelocity.Z,
		delta.Y * delta.Y + delta.X * delta.X + delta.Z * delta.Z
	)

	if solutions then
		for index = 1, #solutions do
			if solutions[index] > 0 then
				local tof = solutions[index] -- time of flight

				return origin + Vector3.new(
					(delta.X + targetVelocity.X * tof) / tof,
					(delta.Y + targetVelocity.Y * tof - gravity * tof * tof) / tof,
					(delta.Z + targetVelocity.Z * tof) / tof
				)
			end
		end
	end

	return targetPosition
end

return module
