// Dashboard JavaScript functionality

// Global variable to track selected slice
let selectedSliceRow = null;

// Function to select a slice and show its details
function selectSlice(sliceId) {
    // Remove previous selection
    if (selectedSliceRow) {
        selectedSliceRow.classList.remove('selected');
    }
    
    // Add selection to current row
    const clickedRow = event.currentTarget;
    clickedRow.classList.add('selected');
    selectedSliceRow = clickedRow;
    
    // Fetch slice details
    fetch(`/slice/${sliceId}`)
        .then(response => {
            if (!response.ok) {
                throw new Error('Network response was not ok');
            }
            return response.json();
        })
        .then(data => {
            showSliceDetails(data);
        })
        .catch(error => {
            console.error('Error fetching slice details:', error);
            alert('Error loading slice details');
        });
}

// Function to display slice details
function showSliceDetails(slice) {
    // Populate detail fields
    document.getElementById('detailId').textContent = slice.id;
    document.getElementById('detailName').textContent = slice.name;
    document.getElementById('detailDescription').textContent = slice.description;
    document.getElementById('detailStatus').textContent = slice.status;
    document.getElementById('detailCreated').textContent = slice.created_at;
    document.getElementById('detailOwner').textContent = slice.owner;
    
    // Apply status styling
    const statusElement = document.getElementById('detailStatus');
    statusElement.className = `status-badge ${slice.status === 'RUNNING' ? 'status-running' : 'status-stopped'}`;
    
    // Show the details panel
    document.getElementById('sliceDetails').style.display = 'block';
    
    // Scroll to details panel
    document.getElementById('sliceDetails').scrollIntoView({ 
        behavior: 'smooth',
        block: 'start'
    });
}

// Add click event listeners to slice links
document.addEventListener('DOMContentLoaded', function() {
    // Prevent default link behavior for slice links
    const sliceLinks = document.querySelectorAll('.slice-link');
    sliceLinks.forEach(link => {
        link.addEventListener('click', function(e) {
            e.preventDefault();
            const sliceId = this.getAttribute('data-slice-id');
            selectSlice(sliceId);
        });
    });
});