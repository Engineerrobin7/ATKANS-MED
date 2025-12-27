import React, { useState, useEffect } from 'react';
import { LayoutDashboard, Users, FileText, Activity, ShieldCheck, LogOut } from 'lucide-react';
import { getStats, getUsers, getAuditLogs, getAccessRequests } from './api';

function App() {
    const [activeTab, setActiveTab] = useState('dashboard');
    const [stats, setStats] = useState({ patients: 0, doctors: 0, reports: 0, active: 0 });

    useEffect(() => {
        const fetchStats = async () => {
            try {
                const response = await getStats();
                setStats(response.data);
            } catch (error) {
                console.error('Error fetching stats:', error);
            }
        };

        fetchStats();
    }, []);

    const renderContent = () => {
        switch (activeTab) {
            case 'dashboard':
                return <DashboardStats stats={stats} />;
            case 'users':
                return <UserList />;
            case 'audit':
                return <AuditLog />;
            case 'access-requests':
                return <AccessRequestList />;
            default:
                return <DashboardStats stats={stats} />;
        }
    };

    return (
        <div className="flex h-screen bg-gray-100">
            {/* Sidebar */}
            <div className="w-64 bg-white shadow-lg">
                <div className="p-6">
                    <h1 className="text-2xl font-bold text-teal-600">Atkans Med</h1>
                    <p className="text-xs text-gray-400">ADMIN PORTAL</p>
                </div>
                <nav className="mt-6">
                    <NavItem icon={<LayoutDashboard size={20} />} label="Dashboard" active={activeTab === 'dashboard'} onClick={() => setActiveTab('dashboard')} />
                    <NavItem icon={<Users size={20} />} label="User Management" active={activeTab === 'users'} onClick={() => setActiveTab('users')} />
                    <NavItem icon={<FileText size={20} />} label="Medical Records" active={activeTab === 'records'} onClick={() => setActiveTab('records')} />
                    <NavItem icon={<Activity size={20} />} label="Audit Logs" active={activeTab === 'audit'} onClick={() => setActiveTab('audit')} />
                    <NavItem icon={<ShieldCheck size={20} />} label="Access Requests" active={activeTab === 'access-requests'} onClick={() => setActiveTab('access-requests')} />
                    <div className="mt-10 border-t pt-4">
                        <NavItem icon={<LogOut size={20} />} label="Logout" active={false} onClick={() => alert('Logout')} />
                    </div>
                </nav>
            </div>

            {/* Main Content */}
            <div className="flex-1 overflow-auto">
                <header className="bg-white shadow-sm p-4 flex justify-between items-center">
                    <h2 className="text-xl font-semibold capitalize">{activeTab}</h2>
                    <div className="flex items-center space-x-4">
                        <span className="text-sm text-gray-600">Admin User</span>
                        <div className="w-8 h-8 bg-teal-500 rounded-full"></div>
                    </div>
                </header>
                <main className="p-8">
                    {renderContent()}
                </main>
            </div>
        </div>
    );
}

function NavItem({ icon, label, active, onClick }) {
    return (
        <button
            onClick={onClick}
            className={`w-full flex items-center space-x-3 px-6 py-3 text-sm font-medium transition-colors ${active ? 'bg-teal-50 text-teal-600 border-r-4 border-teal-600' : 'text-gray-600 hover:bg-gray-50'}`}
        >
            {icon}
            <span>{label}</span>
        </button>
    )
}

function DashboardStats({ stats }) {
    return (
        <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
            <StatCard label="Total Patients" value={stats.patients} icon={<Users className="text-blue-500" />} />
            <StatCard label="Verified Doctors" value={stats.doctors} icon={<ShieldCheck className="text-green-500" />} />
            <StatCard label="Total Reports" value={stats.reports} icon={<FileText className="text-purple-500" />} />
            <StatCard label="Active Sessions" value={stats.active} icon={<Activity className="text-orange-500" />} />
        </div>
    )
}

function StatCard({ label, value, icon }) {
    return (
        <div className="bg-white p-6 rounded-xl shadow-sm hover:shadow-md transition-shadow">
            <div className="flex justify-between items-start">
                <div>
                    <p className="text-sm text-gray-500">{label}</p>
                    <h3 className="text-2xl font-bold mt-1 text-gray-800">{value}</h3>
                </div>
                <div className="p-2 bg-gray-50 rounded-lg">{icon}</div>
            </div>
        </div>
    )
}

function UserList() {
    const [users, setUsers] = useState([]);

    useEffect(() => {
        const fetchUsers = async () => {
            try {
                const response = await getUsers();
                setUsers(response.data);
            } catch (error) {
                console.error('Error fetching users:', error);
            }
        };

        fetchUsers();
    }, []);

    return (
        <div className="bg-white rounded-xl shadow-sm overflow-hidden">
            <table className="w-full text-left">
                <thead className="bg-gray-50 border-b">
                    <tr>
                        <th className="p-4 text-sm font-semibold text-gray-600">Name</th>
                        <th className="p-4 text-sm font-semibold text-gray-600">ID</th>
                        <th className="p-4 text-sm font-semibold text-gray-600">Role</th>
                        <th className="p-4 text-sm font-semibold text-gray-600">Status</th>
                        <th className="p-4 text-sm font-semibold text-gray-600">Action</th>
                    </tr>
                </thead>
                <tbody>
                    {users.map((u, i) => (
                        <tr key={i} className="border-b hover:bg-gray-50">
                            <td className="p-4 font-medium">{u.name}</td>
                            <td className="p-4 text-gray-500 text-sm">{u.id}</td>
                            <td className="p-4 text-sm">{u.role}</td>
                            <td className="p-4">
                                <span className={`px-2 py-1 text-xs rounded-full ${u.status === 'Verified' ? 'bg-green-100 text-green-700' : u.status === 'Active' ? 'bg-blue-100 text-blue-700' : 'bg-yellow-100 text-yellow-700'}`}>
                                    {u.status}
                                </span>
                            </td>
                            <td className="p-4 text-sm text-teal-600 cursor-pointer hover:underline">Manage</td>
                        </tr>
                    ))}
                </tbody>
            </table>
        </div>
    )
}

function AuditLog() {
    const [logs, setLogs] = useState([]);

    useEffect(() => {
        const fetchLogs = async () => {
            try {
                const response = await getAuditLogs();
                setLogs(response.data);
            } catch (error) {
                console.error('Error fetching audit logs:', error);
            }
        };

        fetchLogs();
    }, []);

    return (
        <div className="bg-white rounded-xl shadow-sm p-6">
            <h3 className="text-lg font-bold mb-4">System Activity</h3>
            <ul className="space-y-4">
                {logs.map((log, i) => (
                    <li key={i} className="flex justify-between text-sm">
                        <span>{log.message}</span>
                        <span className="text-gray-400">{log.timestamp}</span>
                    </li>
                ))}
            </ul>
        </div>
    )
}

function AccessRequestList() {
    const [requests, setRequests] = useState([]);

    useEffect(() => {
        const fetchAccessRequests = async () => {
            try {
                const response = await getAccessRequests();
                setRequests(response.data);
            } catch (error) {
                console.error('Error fetching access requests:', error);
            }
        };

        fetchAccessRequests();
    }, []);

    return (
        <div className="bg-white rounded-xl shadow-sm overflow-hidden">
            <table className="w-full text-left">
                <thead className="bg-gray-50 border-b">
                    <tr>
                        <th className="p-4 text-sm font-semibold text-gray-600">Doctor</th>
                        <th className="p-4 text-sm font-semibold text-gray-600">Patient</th>
                        <th className="p-4 text-sm font-semibold text-gray-600">Status</th>
                        <th className="p-4 text-sm font-semibold text-gray-600">Action</th>
                    </tr>
                </thead>
                <tbody>
                    {requests.map((req, i) => (
                        <tr key={i} className="border-b hover:bg-gray-50">
                            <td className="p-4 font-medium">{req.doctor.name}</td>
                            <td className="p-4 text-gray-500 text-sm">{req.patient.name}</td>
                            <td className="p-4">
                                <span className={`px-2 py-1 text-xs rounded-full ${req.status === 'approved' ? 'bg-green-100 text-green-700' : req.status === 'pending' ? 'bg-yellow-100 text-yellow-700' : 'bg-red-100 text-red-700'}`}>
                                    {req.status}
                                </span>
                            </td>
                            <td className="p-4 text-sm text-teal-600 cursor-pointer hover:underline">Manage</td>
                        </tr>
                    ))}
                </tbody>
            </table>
        </div>
    )
}

export default App
