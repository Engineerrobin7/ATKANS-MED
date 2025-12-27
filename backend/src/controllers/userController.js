const { FirestoreHelper, Collections } = require('../config/firestore');

// @desc    Get all users
// @route   GET /api/users
// @access  Private
exports.getUsers = async (req, res) => {
    try {
        const users = await FirestoreHelper.findAll(Collections.USERS);
        // Remove sensitive data
        const sanitizedUsers = users.map(user => {
            const { otpSecret, ...safeUser } = user;
            return safeUser;
        });
        res.status(200).json(sanitizedUsers);
    } catch (error) {
        console.error('Get users error:', error);
        res.status(500).json({ message: error.message });
    }
};

// @desc    Get single user
// @route   GET /api/users/:id
// @access  Private
exports.getUser = async (req, res) => {
    try {
        const user = await FirestoreHelper.findById(Collections.USERS, req.params.id);
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }
        // Remove sensitive data
        const { otpSecret, ...safeUser } = user;
        res.status(200).json(safeUser);
    } catch (error) {
        console.error('Get user error:', error);
        res.status(500).json({ message: error.message });
    }
};

// @desc    Create a user
// @route   POST /api/users
// @access  Private
exports.createUser = async (req, res) => {
    try {
        const { phone, role, name, email } = req.body;

        // Check if user already exists
        const existingUser = await FirestoreHelper.findOne(Collections.USERS, 'phone', phone);
        if (existingUser) {
            return res.status(400).json({ message: 'User with this phone number already exists' });
        }

        const user = await FirestoreHelper.create(Collections.USERS, {
            phone,
            role: role || 'patient',
            name,
            email,
            isVerified: false
        });

        const { otpSecret, ...safeUser } = user;
        res.status(201).json(safeUser);
    } catch (error) {
        console.error('Create user error:', error);
        res.status(500).json({ message: error.message });
    }
};

// @desc    Update a user
// @route   PUT /api/users/:id
// @access  Private
exports.updateUser = async (req, res) => {
    try {
        const user = await FirestoreHelper.findById(Collections.USERS, req.params.id);
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }

        // Don't allow updating sensitive fields
        const { otpSecret, createdAt, ...updateData } = req.body;

        const updatedUser = await FirestoreHelper.updateById(Collections.USERS, req.params.id, updateData);
        const { otpSecret: _, ...safeUser } = updatedUser;
        res.status(200).json(safeUser);
    } catch (error) {
        console.error('Update user error:', error);
        res.status(500).json({ message: error.message });
    }
};

// @desc    Delete a user
// @route   DELETE /api/users/:id
// @access  Private
exports.deleteUser = async (req, res) => {
    try {
        const user = await FirestoreHelper.findById(Collections.USERS, req.params.id);
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }

        await FirestoreHelper.deleteById(Collections.USERS, req.params.id);
        res.status(200).json({ message: 'User deleted successfully' });
    } catch (error) {
        console.error('Delete user error:', error);
        res.status(500).json({ message: error.message });
    }
};
