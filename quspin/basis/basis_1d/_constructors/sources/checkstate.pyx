


cdef NP_INT8_t CheckState_P(int p, unsigned long long s, int L):
	cdef unsigned long long t=s
	t=fliplr(t,L)
	
	if t > s: 
		return 2
	elif t == s:
		if p != -1:
			return 4
		else:
			return -1
	else:
		return -1






cdef NP_INT8_t CheckState_PZ(int pz,unsigned long long s,int L):
	cdef unsigned long long t=s
	
	t=fliplr(t,L)
	t=flip_all(t,L)
	if t > s:
		return 2
	elif t == s:
		if pz != -1:
			return 4
		else:
			return -1
	else:
		return -1





cdef NP_INT8_t CheckState_Z(unsigned long long s,int L):
	cdef unsigned long long t=s

	t=flip_all(t,L)
	if t > s:
		return 2
	else:
		return -1


cdef NP_INT8_t CheckState_P_Z(int p,int z,unsigned long long s,int L):
	cdef NP_INT8_t rp,rz,rps

	rz = CheckState_Z(s,L)
	if rz < 0:
		return -1

	rp = CheckState_P(p,s,L)
	if rp < 0:
		return -1

	rpz = CheckState_PZ(z*p,s,L)
	if rpz < 0:
		return -1	

	return rp*rpz






cdef NP_INT8_t CheckState_ZA(unsigned long long s,int L):
	cdef unsigned long long t=s

	t=flip_sublat_A(t,L)
	if t > s:
		return 2
	else:
		return -1


cdef NP_INT8_t CheckState_ZB(unsigned long long s,int L):
	cdef unsigned long long t=s

	t=flip_sublat_B(t,L)
	if t > s:
		return 2
	else:
		return -1



cdef NP_INT8_t CheckState_ZA_ZB(unsigned long long s,int L):
	cdef unsigned long long t

	t=flip_sublat_A(s,L)
	if t < s:
		return -1

	t=flip_sublat_B(s,L)
	if t < s:
		return -1

	t=flip_all(s,L)
	if t < s:
		return -1

	return 1







cdef NP_INT8_t CheckState_T(int kblock,int L,unsigned long long s,int T):
	# this is a function defined in [1]
	# It is used to check if the integer inputed is a reference state for a state with momentum k.
	#		kblock: the number associated with the momentum (i.e. k=2*pi*kblock/L)
	#		L: length of the system
	#		s: integer which represents a spin config in Sz basis
	#		T: number of sites to translate by, not 1 if the unit cell on the lattice has 2 sites in it.
	cdef unsigned long long t=s
	cdef NP_INT8_t R=-1
	cdef int i
	for i in range(1,L/T+1):
		t = shift(t,-T,L)
		if t < s:
			return R
		elif t == s:
			if kblock % (L/(T*i)) != 0: return R # need to check the shift condition 
			R = i
			return R			










cdef int CheckState_T_P(int kblock,int L,unsigned long long s,int T,_np.ndarray[NP_INT8_t,ndim=1,mode='c'] R):
	# this is a function defined in [1]
	# It is used to check if the integer inputed is a reference state for a state with momentum k.
	#		kblock: the number associated with the momentum (i.e. k=2*pi*kblock/L)
	#		L: length of the system
	#		s: integer which represents a spin config in Sz basis
	#		T: number of sites to translate by, not 1 if the unit cell on the lattice has 2 sites in it.
	cdef unsigned long long t=s
	cdef int i,r
	R[0] = -1
	R[1] = -1
	r = 0

	if CheckState_P(1,s,L) < 0:
		return 0

	for i in range(1,L/T+1):
		t = shift(t,-T,L) 
		if t < s:
			return 0
		elif t==s:
			if kblock % (L/(T*i)) != 0: # need to check the shift condition 
				return 0
			R[0] = i
			r = i
			break

	t = s
	t = fliplr(t,L)
	for i in range(r):
		if t < s:
			R[0] = -1
			return 0
		elif t == s:
			R[1] = i
			break
		t = shift(t,-T,L) 

	return 0




cdef int CheckState_T_P_Z(int kblock,int L,unsigned long long s,int T, _np.ndarray[NP_INT8_t,ndim=1,mode='c'] R):
	# this is a function defined in [1]
	# It is used to check if the integer inputed is a reference state for a state with momentum k.
	#		kblock: the number associated with the momentum (i.e. k=2*pi*kblock/L)
	#		L: length of the system
	#		s: integer which represents a spin config in Sz basis
	#		T: number of sites to translate by, not 1 if the unit cell on the lattice has 2 sites in it.
	cdef unsigned long long t=s
	R[0] = -1
	R[1] = -1
	R[2] = -1
	R[3] = -1

	cdef int i,r
	r = L

	if CheckState_P_Z(1,1,s,L) < 0:
		return 0

	for i in range(1,L/T+1):
		t = shift(t,-T,L)
		if t < s:
			R[0] = -1
			return 0
		elif t==s:
			if kblock % (L/(T*i)) != 0: # need to check the shift condition 
				return 0
			R[0] = i
			r = i
			break	

	t = s
	t = fliplr(t,L)
	for i in range(r):
		if t < s:
			R[0] = -1
			return 0
		elif t == s:
			R[1] = i
			break
		t = shift(t,-T,L) 

	t = s
	t = flip_all(t,L)
	for i in range(r):
		if t < s:
			R[0] = -1
			return 0
		elif t == s:
			R[2] = i
			break
		t = shift(t,-T,L)

	t = s
	t = flip_all(t,L)
	t = fliplr(t,L)
	for i in range(r):
		if t < s:
			R[0] = -1
			return 0
		elif t == s:
			R[3] = i
			break
		t = shift(t,-T,L)	

	return 0












cdef int CheckState_T_PZ(int kblock,int L,unsigned long long s,int T,_np.ndarray[NP_INT8_t,ndim=1,mode='c'] R):
	# this is a function defined in [1]
	# It is used to check if the integer inputed is a reference state for a state with momentum k.
	#		kblock: the number associated with the momentum (i.e. k=2*pi*kblock/L)
	#		L: length of the system
	#		s: integer which represents a spin config in Sz basis
	#		T: number of sites to translate by, not 1 if the unit cell on the lattice has 2 sites in it.
	cdef unsigned long long t=s
	R[0] = -1
	R[1] = -1 
	cdef int i,r

	if CheckState_PZ(1,s,L) < 0:
		return 0

	r = L
	for i in range(1,L/T+1):
		t = shift(t,-T,L)
		if t < s:
			return 0
		elif t==s:
			if kblock % (L/(T*i)) != 0: # need to check the shift condition 
				return 0
			R[0] = i
			r = i
			break

	t = s
	t = flip_all(t,L)
	t = fliplr(t,L)
	for i in range(r):
		if t < s:
			R[0] = -1
			return 0
		elif t == s:
			R[1] = i
			break
		t = shift(t,-T,L) 

	return 0










cdef int CheckState_T_Z(int kblock,int L,unsigned long long s,int T,_np.ndarray[NP_INT8_t,ndim=1,mode='c'] R):
	# this is a function defined in [1]
	# It is used to check if the integer inputed is a reference state for a state with momentum k.
	#		kblock: the number associated with the momentum (i.e. k=2*pi*kblock/L)
	#		L: length of the system
	#		s: integer which represents a spin config in Sz basis
	#		T: number of sites to translate by, not 1 if the unit cell on the lattice has 2 sites in it.
	cdef unsigned long long t=s
	R[0] = -1
	R[1] = -1
	cdef int i,r
	if CheckState_Z(s,L) < 0:
		return 0

	r = L
	for i in range(1,L/T+1):
		t = shift(t,-T,L)
		if t < s:
			return 0
		elif t==s:
			if kblock % (L/(T*i)) != 0: # need to check the shift condition 
				return 0
			R[0] = i
			r = i
			break

	t = s
	t = flip_all(t,L)
	for i in range(r):
		if t < s:
			R[0] = -1
			return 0
		elif t == s:
			R[1] = i
			break
		t = shift(t,-T,L) 

	return 0



cdef int CheckState_T_ZA(int kblock,int L,unsigned long long s,int T,_np.ndarray[NP_INT8_t,ndim=1,mode='c'] R):
	# this is a function defined in [1]
	# It is used to check if the integer inputed is a reference state for a state with momentum k.
	#		kblock: the number associated with the momentum (i.e. k=2*pi*kblock/L)
	#		L: length of the system
	#		s: integer which represents a spin config in Sz basis
	#		T: number of sites to translate by, not 1 if the unit cell on the lattice has 2 sites in it.
	cdef unsigned long long t=s
	R[0] = -1
	R[1] = -1
	cdef int i,r
	if CheckState_ZA(s,L) < 0:
		return 0

	r = L
	for i in range(1,L/T+1):
		t = shift(t,-T,L)
		if t < s:
			return 0
		elif t==s:
			if kblock % (L/(T*i)) != 0: # need to check the shift condition 
				return 0
			R[0] = i
			r = i
			break

	t = s
	t = flip_sublat_A(t,L)
	for i in range(r):
		if t < s:
			R[0] = -1
			return 0
		elif t == s:
			R[1] = i
			break
		t = shift(t,-T,L) 

	return 0


cdef int CheckState_T_ZB(int kblock,int L,unsigned long long s,int T,_np.ndarray[NP_INT8_t,ndim=1,mode='c'] R):
	# this is a function defined in [1]
	# It is used to check if the integer inputed is a reference state for a state with momentum k.
	#		kblock: the number associated with the momentum (i.e. k=2*pi*kblock/L)
	#		L: length of the system
	#		s: integer which represents a spin config in Sz basis
	#		T: number of sites to translate by, not 1 if the unit cell on the lattice has 2 sites in it.
	cdef unsigned long long t=s
	R[0] = -1
	R[1] = -1
	cdef int i,r
	if CheckState_ZB(s,L) < 0:
		return 0

	r = L
	for i in range(1,L/T+1):
		t = shift(t,-T,L)
		if t < s:
			return 0
		elif t==s:
			if kblock % (L/(T*i)) != 0: # need to check the shift condition 
				return 0
			R[0] = i
			r = i
			break

	t = s
	t = flip_sublat_B(t,L)
	for i in range(r):
		if t < s:
			R[0] = -1
			return 0
		elif t == s:
			R[1] = i
			break
		t = shift(t,-T,L) 

	return 0






cdef int CheckState_T_ZA_ZB(int kblock,int L,unsigned long long s,int T,_np.ndarray[NP_INT8_t,ndim=1,mode='c'] R):
	# this is a function defined in [1]
	# It is used to check if the integer inputed is a reference state for a state with momentum k.
	#		kblock: the number associated with the momentum (i.e. k=2*pi*kblock/L)
	#		L: length of the system
	#		s: integer which represents a spin config in Sz basis
	#		T: number of sites to translate by, not 1 if the unit cell on the lattice has 2 sites in it.
	cdef unsigned long long t=s
	R[0] = -1
	R[1] = -1
	R[2] = -1
	R[3] = -1
	cdef int i,r
	if CheckState_ZA_ZB(s,L) < 0:
		return 0


	r = L
	for i in range(1,L/T+1):
		t = shift(t,-T,L)
		if t < s:
			return 0
		elif t==s:
			if kblock % (L/(T*i)) != 0: # need to check the shift condition 
				return 0
			R[0] = i
			r = i
			break


	t = flip_sublat_A(s,L)
	for i in range(r):
		if t < s:
			R[0] = -1
			return 0
		elif t == s:
			R[1] = i
			break
		t = shift(t,-T,L) 


	t = flip_sublat_B(s,L)
	for i in range(r):
		if t < s:
			R[0] = -1
			return 0
		elif t == s:
			R[2] = i
			break
		t = shift(t,-T,L) 


	t = flip_all(s,L)
	for i in range(r):
		if t < s:
			R[0] = -1
			return 0
		elif t == s:
			R[3] = i
			break
		t = shift(t,-T,L) 

	return 0



