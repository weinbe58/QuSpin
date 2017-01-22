


cdef NP_INT8_t CheckState_P_template(bitop fliplr,int p, state_type s, int L, void *bitop_pars):
	cdef state_type t=s
	t=fliplr(t,L,bitop_pars)
	
	if t > s: 
		return 2
	elif t == s:
		if p != -1:
			return 4
		else:
			return -1
	else:
		return -1






cdef NP_INT8_t CheckState_PZ_template(bitop fliplr,bitop flip_all,int pz,state_type s,int L, void *bitop_pars):
	cdef state_type t=s
	
	t=fliplr(t,L,bitop_pars)
	t=flip_all(t,L,bitop_pars)
	if t > s:
		return 2
	elif t == s:
		if pz != -1:
			return 4
		else:
			return -1
	else:
		return -1





cdef NP_INT8_t CheckState_Z_template(bitop flip_all,state_type s,int L, void *bitop_pars):
	cdef state_type t=s

	t=flip_all(t,L,bitop_pars)
	if t > s:
		return 2
	else:
		return -1


cdef NP_INT8_t CheckState_P_Z_template(bitop fliplr,bitop flip_all,int p,int z,state_type s,int L, void *bitop_pars):
	cdef NP_INT8_t rp,rz,rps

	rz = CheckState_Z_template(flip_all,s,L,bitop_pars)
	if rz < 0:
		return -1

	rp = CheckState_P_template(fliplr,p,s,L,bitop_pars)
	if rp < 0:
		return -1

	rpz = CheckState_PZ_template(fliplr,flip_all,z*p,s,L,bitop_pars)
	if rpz < 0:
		return -1	

	return rp*rpz






cdef NP_INT8_t CheckState_ZA_template(bitop flip_sublat_A,state_type s,int L, void *bitop_pars):
	cdef state_type t=s

	t=flip_sublat_A(t,L,bitop_pars)
	if t > s:
		return 2
	else:
		return -1


cdef NP_INT8_t CheckState_ZB_template(bitop flip_sublat_B,state_type s,int L, void *bitop_pars):
	cdef state_type t=s

	t=flip_sublat_B(t,L,bitop_pars)
	if t > s:
		return 2
	else:
		return -1



cdef NP_INT8_t CheckState_ZA_ZB_template(bitop flip_sublat_A,bitop flip_sublat_B,bitop flip_all,state_type s,int L, void *bitop_pars):
	cdef state_type t

	t=flip_sublat_A(s,L,bitop_pars)
	if t < s:
		return -1

	t=flip_sublat_B(s,L,bitop_pars)
	if t < s:
		return -1

	t=flip_all(s,L,bitop_pars)
	if t < s:
		return -1

	return 1







cdef NP_INT8_t CheckState_T_template(shifter shift,int kblock,int L,state_type s,int T, void *bitop_pars):
	# this is a function defined in [1]
	# It is used to check if the integer inputed is a reference state for a state with momentum k.
	#		kblock: the number associated with the momentum (i.e. k=2*pi*kblock/L)
	#		L: length of the system
	#		s: integer which represents a spin config in Sz basis
	#		T: number of sites to translate by, not 1 if the unit cell on the lattice has 2 sites in it.
	cdef state_type t=s
	cdef NP_INT8_t R=-1
	cdef int i
	for i in range(1,L/T+1):
		t = shift(t,-T,L,bitop_pars)
		if t < s:
			return R
		elif t == s:
			if kblock % (L/(T*i)) != 0: return R # need to check the shift condition 
			R = i
			return R			










cdef void CheckState_T_P_template(shifter shift,bitop fliplr,int kblock,int L,state_type s,int T,NP_INT8_t *R, void *bitop_pars):
	# this is a function defined in [1]
	# It is used to check if the integer inputed is a reference state for a state with momentum k.
	#		kblock: the number associated with the momentum (i.e. k=2*pi*kblock/L)
	#		L: length of the system
	#		s: integer which represents a spin config in Sz basis
	#		T: number of sites to translate by, not 1 if the unit cell on the lattice has 2 sites in it.
	cdef state_type t=s
	cdef int i,r
	R[0] = -1
	R[1] = -1
	r = 0

	if CheckState_P_template(fliplr,1,s,L,bitop_pars) < 0:
		return

	for i in range(1,L/T+1):
		t = shift(t,-T,L,bitop_pars) 
		if t < s:
			return
		elif t==s:
			if kblock % (L/(T*i)) != 0: # need to check the shift condition 
				return
			R[0] = i
			r = i
			break

	t = s
	t = fliplr(t,L,bitop_pars)
	for i in range(r):
		if t < s:
			R[0] = -1
			return
		elif t == s:
			R[1] = i
			break
		t = shift(t,-T,L,bitop_pars) 

	return




cdef void CheckState_T_P_Z_template(shifter shift,bitop fliplr,bitop flip_all,int kblock,int L,state_type s,int T, NP_INT8_t *R, void *bitop_pars):
	# this is a function defined in [1]
	# It is used to check if the integer inputed is a reference state for a state with momentum k.
	#		kblock: the number associated with the momentum (i.e. k=2*pi*kblock/L)
	#		L: length of the system
	#		s: integer which represents a spin config in Sz basis
	#		T: number of sites to translate by, not 1 if the unit cell on the lattice has 2 sites in it.
	cdef state_type t=s
	R[0] = -1
	R[1] = -1
	R[2] = -1
	R[3] = -1

	cdef int i,r
	r = L

	if CheckState_P_Z_template(fliplr,flip_all,1,1,s,L,bitop_pars) < 0:
		return

	for i in range(1,L/T+1):
		t = shift(t,-T,L,bitop_pars)
		if t < s:
			R[0] = -1
			return
		elif t==s:
			if kblock % (L/(T*i)) != 0: # need to check the shift condition 
				return
			R[0] = i
			r = i
			break	

	t = s
	t = fliplr(t,L,bitop_pars)
	for i in range(r):
		if t < s:
			R[0] = -1
			return
		elif t == s:
			R[1] = i
			break
		t = shift(t,-T,L,bitop_pars) 

	t = s
	t = flip_all(t,L,bitop_pars)
	for i in range(r):
		if t < s:
			R[0] = -1
			return
		elif t == s:
			R[2] = i
			break
		t = shift(t,-T,L,bitop_pars)

	t = s
	t = flip_all(t,L,bitop_pars)
	t = fliplr(t,L,bitop_pars)
	for i in range(r):
		if t < s:
			R[0] = -1
			return
		elif t == s:
			R[3] = i
			break
		t = shift(t,-T,L,bitop_pars)	

	return












cdef void CheckState_T_PZ_template(shifter shift,bitop fliplr,bitop flip_all,int kblock,int L,state_type s,int T,NP_INT8_t *R, void *bitop_pars):
	# this is a function defined in [1]
	# It is used to check if the integer inputed is a reference state for a state with momentum k.
	#		kblock: the number associated with the momentum (i.e. k=2*pi*kblock/L)
	#		L: length of the system
	#		s: integer which represents a spin config in Sz basis
	#		T: number of sites to translate by, not 1 if the unit cell on the lattice has 2 sites in it.
	cdef state_type t=s
	R[0] = -1
	R[1] = -1 
	cdef int i,r

	if CheckState_PZ_template(fliplr,flip_all,1,s,L,bitop_pars) < 0:
		return

	r = L
	for i in range(1,L/T+1):
		t = shift(t,-T,L,bitop_pars)
		if t < s:
			return
		elif t==s:
			if kblock % (L/(T*i)) != 0: # need to check the shift condition 
				return
			R[0] = i
			r = i
			break

	t = s
	t = flip_all(t,L,bitop_pars)
	t = fliplr(t,L,bitop_pars)
	for i in range(r):
		if t < s:
			R[0] = -1
			return
		elif t == s:
			R[1] = i
			break
		t = shift(t,-T,L,bitop_pars) 

	return










cdef void CheckState_T_Z_template(shifter shift,bitop flip_all,int kblock,int L,state_type s,int T,NP_INT8_t *R, void *bitop_pars):
	# this is a function defined in [1]
	# It is used to check if the integer inputed is a reference state for a state with momentum k.
	#		kblock: the number associated with the momentum (i.e. k=2*pi*kblock/L)
	#		L: length of the system
	#		s: integer which represents a spin config in Sz basis
	#		T: number of sites to translate by, not 1 if the unit cell on the lattice has 2 sites in it.
	cdef state_type t=s
	R[0] = -1
	R[1] = -1
	cdef int i,r
	if CheckState_Z_template(flip_all,s,L,bitop_pars) < 0:
		return

	r = L
	for i in range(1,L/T+1):
		t = shift(t,-T,L,bitop_pars)
		if t < s:
			return
		elif t==s:
			if kblock % (L/(T*i)) != 0: # need to check the shift condition 
				return
			R[0] = i
			r = i
			break

	t = s
	t = flip_all(t,L,bitop_pars)
	for i in range(r):
		if t < s:
			R[0] = -1
			return
		elif t == s:
			R[1] = i
			break
		t = shift(t,-T,L,bitop_pars) 

	return



cdef void CheckState_T_ZA_template(shifter shift,bitop flip_sublat_A,int kblock,int L,state_type s,int T,NP_INT8_t *R, void *bitop_pars):
	# this is a function defined in [1]
	# It is used to check if the integer inputed is a reference state for a state with momentum k.
	#		kblock: the number associated with the momentum (i.e. k=2*pi*kblock/L)
	#		L: length of the system
	#		s: integer which represents a spin config in Sz basis
	#		T: number of sites to translate by, not 1 if the unit cell on the lattice has 2 sites in it.
	cdef state_type t=s
	R[0] = -1
	R[1] = -1
	cdef int i,r
	if CheckState_ZA_template(flip_sublat_A,s,L,bitop_pars) < 0:
		return

	r = L
	for i in range(1,L/T+1):
		t = shift(t,-T,L,bitop_pars)
		if t < s:
			return
		elif t==s:
			if kblock % (L/(T*i)) != 0: # need to check the shift condition 
				return
			R[0] = i
			r = i
			break

	t = s
	t = flip_sublat_A(t,L,bitop_pars)
	for i in range(r):
		if t < s:
			R[0] = -1
			return
		elif t == s:
			R[1] = i
			break
		t = shift(t,-T,L,bitop_pars) 

	return


cdef void CheckState_T_ZB_template(shifter shift,bitop flip_sublat_B,int kblock,int L,state_type s,int T,NP_INT8_t *R, void *bitop_pars):
	# this is a function defined in [1]
	# It is used to check if the integer inputed is a reference state for a state with momentum k.
	#		kblock: the number associated with the momentum (i.e. k=2*pi*kblock/L)
	#		L: length of the system
	#		s: integer which represents a spin config in Sz basis
	#		T: number of sites to translate by, not 1 if the unit cell on the lattice has 2 sites in it.
	cdef state_type t=s
	R[0] = -1
	R[1] = -1
	cdef int i,r
	if CheckState_ZB_template(flip_sublat_B,s,L,bitop_pars) < 0:
		return

	r = L
	for i in range(1,L/T+1):
		t = shift(t,-T,L,bitop_pars)
		if t < s:
			return
		elif t==s:
			if kblock % (L/(T*i)) != 0: # need to check the shift condition 
				return
			R[0] = i
			r = i
			break

	t = s
	t = flip_sublat_B(t,L,bitop_pars)
	for i in range(r):
		if t < s:
			R[0] = -1
			return
		elif t == s:
			R[1] = i
			break
		t = shift(t,-T,L,bitop_pars) 

	return






cdef void CheckState_T_ZA_ZB_template(shifter shift,bitop flip_sublat_A,bitop flip_sublat_B,bitop flip_all,int kblock,int L,state_type s,int T,NP_INT8_t *R, void *bitop_pars):
	# this is a function defined in [1]
	# It is used to check if the integer inputed is a reference state for a state with momentum k.
	#		kblock: the number associated with the momentum (i.e. k=2*pi*kblock/L)
	#		L: length of the system
	#		s: integer which represents a spin config in Sz basis
	#		T: number of sites to translate by, not 1 if the unit cell on the lattice has 2 sites in it.
	cdef state_type t=s
	R[0] = -1
	R[1] = -1
	R[2] = -1
	R[3] = -1
	cdef int i,r
	if CheckState_ZA_ZB_template(flip_sublat_A,flip_sublat_B,flip_all,s,L,bitop_pars) < 0:
		return


	r = L
	for i in range(1,L/T+1):
		t = shift(t,-T,L,bitop_pars)
		if t < s:
			return
		elif t==s:
			if kblock % (L/(T*i)) != 0: # need to check the shift condition 
				return
			R[0] = i
			r = i
			break


	t = flip_sublat_A(s,L,bitop_pars)
	for i in range(r):
		if t < s:
			R[0] = -1
			return
		elif t == s:
			R[1] = i
			break
		t = shift(t,-T,L,bitop_pars) 


	t = flip_sublat_B(s,L,bitop_pars)
	for i in range(r):
		if t < s:
			R[0] = -1
			return
		elif t == s:
			R[2] = i
			break
		t = shift(t,-T,L,bitop_pars) 


	t = flip_all(s,L,bitop_pars)
	for i in range(r):
		if t < s:
			R[0] = -1
			return
		elif t == s:
			R[3] = i
			break
		t = shift(t,-T,L,bitop_pars) 

	return



